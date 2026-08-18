# routes/vba_api.py
"""API endpoints called by the Access (VBA) client.

Replaces every direct use of the MySQL Admin account in the desktop app.
All endpoints are prefixed with /api/vba and require the static X-API-Key
header, which only filters automated scanners - real protection comes from
the per-email rate limiting and the server-side K1 comparison.
"""

import os
import re
import secrets
import logging
from functools import wraps

import redis
from flask import Blueprint, request, jsonify
from mysql.connector import Error as MySQLError, connect

from modules.vba_db import get_vba_conn
from modules.vba_mailer import send_mail

vba_bp = Blueprint("vba_api", __name__, url_prefix="/api/vba")

logger = logging.getLogger("vba_api")

VBA_API_KEY = os.getenv("VBA_API_KEY", "")

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", 3306))
DB_NAME = os.getenv("DB_NAME", "SVN_00")

redis_client = redis.Redis(
    host=os.getenv("REDIS_HOST", "localhost"),
    port=int(os.getenv("REDIS_PORT", 6379)),
    db=int(os.getenv("REDIS_DB", 0)),
    password=os.getenv("REDIS_PASSWORD"),
    decode_responses=True,
)

MAX_ATTEMPTS = 5
BLOCK_SECONDS = 3600
ATTEMPT_WINDOW = 1800


# ========== HELPERS ==========

def require_api_key(f):
    """Reject requests without the shared static key."""
    @wraps(f)
    def wrapper(*args, **kwargs):
        supplied = request.headers.get("X-API-Key", "")
        if not VBA_API_KEY or not secrets.compare_digest(supplied, VBA_API_KEY):
            logger.warning(f"Bad API key from {request.remote_addr} on {request.path}")
            return jsonify({"success": False, "message": "Acces respins."}), 401
        return f(*args, **kwargs)
    return wrapper


def normalize_email(value):
    """Uppercase and strip whitespace, matching the VBA client behaviour."""
    if not value:
        return ""
    return re.sub(r"\s+", "", str(value)).upper()


def is_blocked(email):
    return redis_client.exists(f"vba_blocked:{email}") == 1


def register_failure(email):
    """Count a failed attempt and block the email after MAX_ATTEMPTS."""
    key = f"vba_attempts:{email}"
    count = int(redis_client.incr(key))
    if count == 1:
        redis_client.expire(key, ATTEMPT_WINDOW)
    if count >= MAX_ATTEMPTS:
        redis_client.setex(f"vba_blocked:{email}", BLOCK_SECONDS, "1")
        logger.error(f"Email blocked after {count} failures: {email}")
    return count


def clear_failures(email):
    redis_client.delete(f"vba_attempts:{email}")


def db_query(sql, params=None, one=False):
    """Run a SELECT on the VBA pool and return dict rows."""
    conn = None
    cursor = None
    try:
        conn = get_vba_conn()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(sql, params or ())
        return cursor.fetchone() if one else cursor.fetchall()
    finally:
        if cursor:
            try: cursor.close()
            except Exception: pass
        if conn:
            try: conn.close()
            except Exception: pass


def set_audit_user(cursor, id_consultant):
    """Tell the DB triggers who is really acting, since SESSION_USER() is flask_user.

    Must be called on the same connection, before any INSERT/UPDATE on
    tables that carry the Consultanti_*_AFTER audit triggers.
    """
    cursor.execute("SET @app_user_id = %s", (int(id_consultant),))

# ========== ENDPOINTS ==========

@vba_bp.route("/consultant-lookup", methods=["POST"])
@require_api_key
def consultant_lookup():
    """Replaces the SQL_ADM query in cMail_AfterUpdate and Form_Load.

    Accepts either an email address or an IdConsultant. K1 is deliberately
    NOT returned - the key comparison now happens server-side in /verify-key.
    K2 is returned as the UseTestDB flag only.
    """
    try:
        data = request.get_json(silent=True) or {}
        email = normalize_email(data.get("email"))
        raw_id = data.get("IdConsultant")

        lookup_id = None
        if raw_id not in (None, "", 0, "0"):
            try:
                lookup_id = int(raw_id)
            except (TypeError, ValueError):
                lookup_id = None

        if lookup_id is None and (not email or len(email) < 6):
            return jsonify({"success": False, "message": "Date incomplete."}), 400

        block_key = email if email else f"ID{lookup_id}"
        if is_blocked(block_key):
            return jsonify({"success": False, "message": "Cont blocat temporar. Reincercati mai tarziu."}), 403

        base_sql = (
            "SELECT IdConsultant, NumeConsultant, cMail, SchimbaParola, Parola_Resetata, "
            "Nou, IdNivel, K2, ConnectionID, Rol_Update, BazePermise "
            "FROM SVN_00.Consultanti WHERE {0} AND Plecat = 0"
        )

        if lookup_id is not None:
            row = db_query(base_sql.format("IdConsultant = %s"), (lookup_id,), one=True)
        else:
            row = db_query(base_sql.format("UPPER(cMail) = %s"), (email,), one=True)

        if not row:
            count = register_failure(block_key)
            logger.warning(f"Unknown consultant {block_key} attempt {count} from {request.remote_addr}")
            return jsonify({"success": False, "message": "Nu am gasit un utilizator activ cu aceasta adresa de e-mail!"}), 404

        clear_failures(block_key)

        use_test_db = 0
        if row.get("K2") not in (None, ""):
            try:
                use_test_db = int(row["K2"])
            except (TypeError, ValueError):
                use_test_db = 0

        return jsonify({
            "success": True,
            "IdConsultant": row["IdConsultant"],
            "NumeConsultant": row["NumeConsultant"],
            "cMail": row["cMail"],
            "SchimbaParola": int(row["SchimbaParola"] or 0),
            "Parola_Resetata": int(row["Parola_Resetata"] or 0),
            "Nou": int(row["Nou"] or 0),
            "IdNivel": int(row["IdNivel"] or 0),
            "ConnectionID": int(row["ConnectionID"] or 0),
            "Rol_Update": int(row["Rol_Update"] or 0),
            "BazePermise": row["BazePermise"],
            "UseTestDB": use_test_db,
        })

    except Exception as e:
        logger.error(f"consultant_lookup error: {e}")
        return jsonify({"success": False, "message": "Eroare tehnica la interogarea serverului."}), 500


@vba_bp.route("/verify-key", methods=["POST"])
@require_api_key
def verify_key():
    """Replaces the client-side StrComp(tParola, cheie) check in OK_Click.

    K1 never leaves the server. Used when Nou = 1 or Parola_Resetata = 1.
    """
    try:
        data = request.get_json(silent=True) or {}
        email = normalize_email(data.get("email"))
        supplied_key = str(data.get("key") or "")

        if not email or not supplied_key:
            return jsonify({"success": False, "message": "Date incomplete."}), 400

        if is_blocked(email):
            return jsonify({"success": False, "message": "Cont blocat temporar. Reincercati mai tarziu."}), 403

        row = db_query(
            "SELECT IdConsultant, K1 FROM SVN_00.Consultanti "
            "WHERE UPPER(cMail) = %s AND Plecat = 0 AND Ascuns = 0",
            (email,), one=True
        )

        if not row:
            register_failure(email)
            return jsonify({"success": False, "message": "Nu am gasit un utilizator activ cu aceasta adresa de e-mail!"}), 404

        stored_key = str(row.get("K1") or "")

        # Case-insensitive comparison, matching vbTextCompare in the VBA original
        if not stored_key or not secrets.compare_digest(supplied_key.upper(), stored_key.upper()):
            count = register_failure(email)
            logger.warning(f"Bad K1 for {email} attempt {count} from {request.remote_addr}")
            return jsonify({"success": False, "message": "Cheia introdusa NU este corecta!"}), 401

        clear_failures(email)
        return jsonify({"success": True, "IdConsultant": row["IdConsultant"]})

    except Exception as e:
        logger.error(f"verify_key error: {e}")
        return jsonify({"success": False, "message": "Eroare tehnica la verificarea cheii."}), 500


@vba_bp.route("/request-reset", methods=["POST"])
@require_api_key
def request_reset():
    """Replaces Popup_frmConectare Case 3.

    Validates K1 server-side, writes the audit row into LOG.RESET and
    sets SchimbaParola = 1. The Consultanti_MOD_BEFORE trigger regenerates
    K1 as part of that update, so the new key is read back after commit
    and mailed to the consultant.
    """
    conn = None
    cursor = None
    try:
        data = request.get_json(silent=True) or {}
        email = normalize_email(data.get("email"))
        supplied_key = str(data.get("key") or "")
        user_name = str(data.get("userName") or "")[:255]
        computer_name = str(data.get("computerName") or "")[:255]
        client_ip = request.remote_addr or ""

        # SetariADC lives in each department database, not in SVN_00
        department = str(data.get("department") or "").strip().upper()
        if department not in ("SVN_IM", "SVN_NP", "SVN_AS", "SVN_TEST"):
            return jsonify({"success": False, "message": "Baza de date invalida."}), 400

        if not email or not supplied_key:
            return jsonify({"success": False, "message": "Date incomplete."}), 400

        if is_blocked(email):
            return jsonify({"success": False, "message": "Cont blocat temporar. Reincercati mai tarziu."}), 403

        conn = get_vba_conn()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            "SELECT IdConsultant, NumeConsultant, cMail, K1 FROM SVN_00.Consultanti "
            "WHERE UPPER(cMail) = %s AND Plecat = 0 AND Ascuns = 0",
            (email,)
        )
        row = cursor.fetchone()

        if not row:
            register_failure(email)
            return jsonify({"success": False, "message": "Nu am gasit un utilizator activ cu aceasta adresa de e-mail!"}), 404

        stored_key = str(row.get("K1") or "")

        if not stored_key or not secrets.compare_digest(supplied_key.upper(), stored_key.upper()):
            count = register_failure(email)
            logger.warning(f"Bad K1 on reset for {email} attempt {count} from {request.remote_addr}")
            return jsonify({"success": False, "message": "Cheia introdusa NU este corecta!"}), 401

        id_consultant = row["IdConsultant"]
        consultant_name = str(row.get("NumeConsultant") or "")
        consultant_mail = str(row.get("cMail") or "").strip()

        conn.start_transaction()
        set_audit_user(cursor, id_consultant)

        cursor.execute(
            "INSERT INTO LOG.RESET (IdConsultant, IP, UserName, ComputerName) VALUES (%s, %s, %s, %s)",
            (id_consultant, client_ip, user_name, computer_name)
        )
        cursor.execute(
            "UPDATE SVN_00.Consultanti SET SchimbaParola = 1 WHERE IdConsultant = %s",
            (id_consultant,)
        )

        if cursor.rowcount != 1:
            conn.rollback()
            return jsonify({"success": False, "message": "Nu s-au putut scrie datele pe server!"}), 500

        conn.commit()
        clear_failures(email)

        logger.info(f"Password reset requested for IdConsultant={id_consultant} from {client_ip}")

        # The MOD_BEFORE trigger replaced K1 during the update - read it back
        cursor.execute(
            "SELECT K1 FROM SVN_00.Consultanti WHERE IdConsultant = %s",
            (id_consultant,)
        )
        new_row = cursor.fetchone()
        new_key = str(new_row.get("K1") or "") if new_row else ""

        # Mail failure does not roll back: the key is already replaced, so a
        # rollback would leave the consultant with a dead key either way
        mail_sent = False
        mail_message = ""

        if not new_key:
            mail_message = "Cheia noua nu a putut fi citita de pe server!"
            logger.error(f"Reset for {id_consultant}: K1 missing after update")
        elif not consultant_mail:
            mail_message = "Utilizatorul nu are adresa de email configurata!"
            logger.error(f"Reset for {id_consultant}: no email address on file")
        else:
            cursor.execute(
                f"SELECT Valoare FROM `{department}`.SetariADC WHERE Setare = 'DATE_USER'"
            )
            template_row = cursor.fetchone()

            if not template_row or not template_row.get("Valoare"):
                mail_message = "Sablonul de email nu este configurat!"
                logger.error(f"Reset for {id_consultant}: DATE_USER template missing in {department}")
            else:
                body = str(template_row["Valoare"]).replace("[uname]", consultant_name).replace("[cheie]", new_key)
                mail_sent = send_mail("Date conectare CRM AD.CREDIT", consultant_mail, body)

                if not mail_sent:
                    mail_message = "Cheia a fost resetata dar emailul nu a putut fi trimis! Contactati team-leaderul."
                    logger.error(f"Reset for {id_consultant}: mail to {consultant_mail} failed")

        return jsonify({
            "success": True,
            "IdConsultant": id_consultant,
            "mailSent": mail_sent,
            "message": mail_message if not mail_sent else "Cheia noua a fost trimisa pe email!",
        })

    except Exception as e:
        if conn:
            try: conn.rollback()
            except Exception: pass
        logger.error(f"request_reset error: {e}")
        return jsonify({"success": False, "message": "Eroare tehnica la resetarea parolei."}), 500

    finally:
        if cursor:
            try: cursor.close()
            except Exception: pass
        if conn:
            try: conn.close()
            except Exception: pass

@vba_bp.route("/change-password", methods=["POST"])
@require_api_key
def change_password():
    """Replaces Form_InputBoxNewPass.OK_Click.

    The caller must prove identity with the current K1 before the MySQL
    password is altered. Password rules mirror the original regex.
    """
    conn = None
    cursor = None
    try:
        data = request.get_json(silent=True) or {}
        email = normalize_email(data.get("email"))
        supplied_key = str(data.get("key") or "")
        new_password = str(data.get("newPassword") or "")

        if not email or not supplied_key or not new_password:
            return jsonify({"success": False, "message": "Date incomplete."}), 400

        if is_blocked(email):
            return jsonify({"success": False, "message": "Cont blocat temporar. Reincercati mai tarziu."}), 403

        # Same rules as the original: min 10 chars, letter + digit + special
        if len(new_password) < 10:
            return jsonify({"success": False, "message": "Parola nu corespunde cerintelor de securitate!"}), 400
        if not re.search(r"[a-zA-Z]", new_password):
            return jsonify({"success": False, "message": "Parola nu corespunde cerintelor de securitate!"}), 400
        if not re.search(r"[0-9]", new_password):
            return jsonify({"success": False, "message": "Parola nu corespunde cerintelor de securitate!"}), 400
        if not re.search(r"[.!@#$%^&*()]", new_password):
            return jsonify({"success": False, "message": "Parola nu corespunde cerintelor de securitate!"}), 400

        conn = get_vba_conn()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            "SELECT IdConsultant, K1 FROM SVN_00.Consultanti "
            "WHERE UPPER(cMail) = %s AND Plecat = 0 AND Ascuns = 0",
            (email,)
        )
        row = cursor.fetchone()

        if not row:
            register_failure(email)
            return jsonify({"success": False, "message": "Nu am gasit un utilizator activ cu aceasta adresa de e-mail!"}), 404

        stored_key = str(row.get("K1") or "")

        if not stored_key or not secrets.compare_digest(supplied_key.upper(), stored_key.upper()):
            count = register_failure(email)
            logger.warning(f"Bad K1 on password change for {email} attempt {count}")
            return jsonify({"success": False, "message": "Cheia introdusa NU este corecta!"}), 401

        id_consultant = row["IdConsultant"]
        mysql_user = f"C{id_consultant:03d}"

        # ALTER USER cannot be parameterised - the identifier is built from an
        # integer and the password is escaped by the connector
        escaped = new_password.replace("\\", "\\\\").replace("'", "\\'")
        cursor.execute(f"ALTER USER `{mysql_user}`@`%` IDENTIFIED BY '{escaped}'")

        cursor.execute(
            "UPDATE SVN_00.Consultanti SET Parola_Resetata = 0, Nou = 0, SchimbaParola = 0 "
            "WHERE IdConsultant = %s",
            (id_consultant,)
        )
        conn.commit()

        clear_failures(email)
        logger.info(f"Password changed for {mysql_user}")
        return jsonify({"success": True, "IdConsultant": id_consultant})

    except MySQLError as e:
        if conn:
            try: conn.rollback()
            except Exception: pass
        logger.error(f"change_password MySQL error: {e}")
        return jsonify({"success": False, "message": "Parola utilizatorului nu a putut fi stabilita!"}), 500

    except Exception as e:
        if conn:
            try: conn.rollback()
            except Exception: pass
        logger.error(f"change_password error: {e}")
        return jsonify({"success": False, "message": "Eroare tehnica la schimbarea parolei."}), 500

    finally:
        if cursor:
            try: cursor.close()
            except Exception: pass
        if conn:
            try: conn.close()
            except Exception: pass


@vba_bp.route("/check-role", methods=["POST"])
@require_api_key
def check_role():
    """Replaces the mysql.user default_role lookup in OK_Click."""
    try:
        data = request.get_json(silent=True) or {}
        id_consultant = data.get("IdConsultant")

        try:
            id_consultant = int(id_consultant)
        except (TypeError, ValueError):
            return jsonify({"success": False, "message": "IdConsultant invalid."}), 400

        mysql_user = f"C{id_consultant:03d}"

        row = db_query(
            "SELECT default_role FROM mysql.user WHERE user = %s",
            (mysql_user,), one=True
        )

        if not row:
            return jsonify({"success": False, "message": "Utilizatorul nu exista pe server!"}), 404

        default_role = str(row.get("default_role") or "")

        if not default_role:
            return jsonify({"success": False, "message": "Nu s-a putut stabili rolul utilizatorului! Incearca mai tarziu!"}), 409

        return jsonify({"success": True, "default_role": default_role})

    except Exception as e:
        logger.error(f"check_role error: {e}")
        return jsonify({"success": False, "message": "Eroare tehnica la verificarea rolului."}), 500


# ========== POST-LOGIN ENDPOINTS ==========
# These require the caller to prove identity with their own MySQL credentials.
# Authorization rules that used to live in the Access form are enforced here.

def authenticate_caller(email, password):
    """Verify the caller by opening a MySQL connection with their own account.

    Returns the caller's consultant row on success, None on failure.
    """
    email = normalize_email(email)
    if not email or not password:
        return None

    row = db_query(
        "SELECT IdConsultant, IdNivel, IdParinte, NumeConsultant "
        "FROM SVN_00.Consultanti WHERE UPPER(cMail) = %s AND Plecat = 0 AND Ascuns = 0",
        (email,), one=True
    )
    if not row:
        return None

    mysql_user = f"C{row['IdConsultant']:03d}"
    test_conn = None
    try:
        test_conn = connect(
            host=DB_HOST, port=DB_PORT, user=mysql_user,
            password=password, database=DB_NAME,
            ssl_disabled=False, ssl_verify_cert=False,
        )
        return row
    except MySQLError:
        return None
    finally:
        if test_conn:
            try: test_conn.close()
            except Exception: pass


def has_right(id_consultant, id_drept):
    """Check a single entry in Consultanti_Drepturi (mirrors Drepturi() in VBA)."""
    row = db_query(
        "SELECT Valoare FROM SVN_00.Consultanti_Drepturi "
        "WHERE IdConsultant = %s AND IdDrept = %s",
        (id_consultant, id_drept), one=True
    )
    if not row:
        return False
    try:
        return int(row["Valoare"]) != 0
    except (TypeError, ValueError):
        return False


def is_descendant(ancestor_id, target_id):
    """Walk the IdParinte chain upwards to see if target is under ancestor."""
    if ancestor_id == target_id:
        return True

    current = target_id
    for _ in range(20):  # depth guard against a corrupted parent chain
        row = db_query(
            "SELECT IdParinte FROM SVN_00.Consultanti WHERE IdConsultant = %s",
            (current,), one=True
        )
        if not row or row["IdParinte"] in (None, 0):
            return False
        if int(row["IdParinte"]) == ancestor_id:
            return True
        current = int(row["IdParinte"])
    return False


def role_for_level(id_nivel):
    """Look up the MySQL role prefix for a given level."""
    row = db_query(
        "SELECT Prefix FROM SVN_00.Niveluri WHERE IdNivel = %s",
        (id_nivel,), one=True
    )
    if not row or not row.get("Prefix"):
        return None
    return str(row["Prefix"]).strip()


def generate_k1():
    """Server-side K1, replacing GenerateRandomString(10) in the Access client."""
    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    return "".join(secrets.choice(alphabet) for _ in range(10)) + "!"


@vba_bp.route("/save-consultant", methods=["POST"])
@require_api_key
def save_consultant():
    """Replaces Form_Utilizatori.bSav_Click (tabCtl = 0).

    Handles both insert and update, plus CREATE USER / GRANT / REVOKE /
    SET DEFAULT ROLE, all inside one transaction.
    """
    conn = None
    cursor = None
    try:
        data = request.get_json(silent=True) or {}

        caller = authenticate_caller(data.get("callerEmail"), data.get("callerPassword"))
        if not caller:
            return jsonify({"success": False, "message": "Autentificare esuata."}), 401

        caller_id = int(caller["IdConsultant"])
        caller_level = int(caller["IdNivel"] or 0)

        is_edit = bool(data.get("isEdit"))
        target_id = data.get("IdConsultant")
        nume = str(data.get("NumeConsultant") or "").strip().upper()
        telefon = str(data.get("cTelefon") or "").strip()
        # Store the address as typed; comparisons are case-insensitive via UPPER()
        cmail = str(data.get("cMail") or "").strip()
        id_parinte = data.get("IdParinte")
        id_nivel = data.get("IdNivel")
        plecat = 1 if data.get("Plecat") else 0

        if not nume or not telefon or not cmail:
            return jsonify({"success": False, "message": "Completati toate campurile obligatorii!"}), 400

        try:
            id_nivel = int(id_nivel)
        except (TypeError, ValueError):
            return jsonify({"success": False, "message": "Nivel invalid."}), 400

        id_parinte = int(id_parinte) if id_parinte not in (None, "", 0) else None

        # ----- authorization -----
        required_right = 2 if is_edit else 1
        if not has_right(caller_id, required_right):
            return jsonify({"success": False, "message": "Nu aveti dreptul de a efectua aceasta operatiune!"}), 403

        if plecat and not has_right(caller_id, 21):
            return jsonify({"success": False, "message": "Nu aveti dreptul de a marca un utilizator ca plecat!"}), 403

        if caller_level < 40:
            if id_nivel >= caller_level:
                return jsonify({"success": False, "message": "Nu puteti stabili un nivel mai mare sau egal cu al dumneavoastra!"}), 403
            if is_edit and target_id is not None and not is_descendant(caller_id, int(target_id)):
                return jsonify({"success": False, "message": "Puteti modifica doar utilizatorii din subordinea dumneavoastra!"}), 403
            if id_parinte is not None and not is_descendant(caller_id, id_parinte):
                return jsonify({"success": False, "message": "Parintele ales nu este in subordinea dumneavoastra!"}), 403
        elif id_nivel > 40:
            return jsonify({"success": False, "message": "Nivelul maxim admis este 40!"}), 403

        new_role = role_for_level(id_nivel)
        if not new_role:
            return jsonify({"success": False, "message": "Nu exista un rol definit pentru acest nivel!"}), 400

        conn = get_vba_conn()
        cursor = conn.cursor(dictionary=True)
        conn.start_transaction()
        set_audit_user(cursor, caller_id)

        # ----- duplicate checks -----
        dup_sql = ("SELECT IdConsultant FROM SVN_00.Consultanti "
                   "WHERE REGEXP_REPLACE({0}, '\\\\s+', '') = %s AND IdConsultant <> %s")
        guard_id = int(target_id) if is_edit and target_id is not None else -1

        cursor.execute(dup_sql.format("UPPER(NumeConsultant)"), (re.sub(r"\s+", "", nume), guard_id))
        if cursor.fetchone():
            conn.rollback()
            return jsonify({"success": False, "message": "Exista deja un consultant cu acest nume!"}), 409

        cursor.execute(dup_sql.format("cTelefon"), (re.sub(r"\s+", "", telefon), guard_id))
        if cursor.fetchone():
            conn.rollback()
            return jsonify({"success": False, "message": "Exista deja un consultant cu acest numar de telefon!"}), 409

        cursor.execute(dup_sql.format("UPPER(cMail)"), (re.sub(r"\s+", "", cmail).upper(), guard_id))
        if cursor.fetchone():
            conn.rollback()
            return jsonify({"success": False, "message": "Exista deja un consultant cu aceasta adresa de e-mail!"}), 409

        if is_edit:
            # ----- UPDATE path -----
            try:
                target_id = int(target_id)
            except (TypeError, ValueError):
                conn.rollback()
                return jsonify({"success": False, "message": "IdConsultant invalid."}), 400

            cursor.execute(
                "SELECT IdNivel FROM SVN_00.Consultanti WHERE IdConsultant = %s",
                (target_id,)
            )
            existing = cursor.fetchone()
            if not existing:
                conn.rollback()
                return jsonify({"success": False, "message": "Utilizatorul nu exista!"}), 404

            old_role = role_for_level(int(existing["IdNivel"] or 0))
            role_changed = (old_role or "").upper() != new_role.upper()

            cursor.execute(
                "UPDATE SVN_00.Consultanti SET NumeConsultant = %s, cTelefon = %s, cMail = %s, "
                "IdParinte = %s, IdNivel = %s, Plecat = %s WHERE IdConsultant = %s",
                (nume, telefon, cmail, id_parinte, id_nivel, plecat, target_id)
            )

            mysql_user = f"C{target_id:03d}"

            if role_changed:
                cursor.execute(f"REVOKE ALL PRIVILEGES, GRANT OPTION FROM `{mysql_user}`@`%`")
                cursor.execute(f"GRANT `{new_role}` TO `{mysql_user}`@`%`")
                cursor.execute(f"SET DEFAULT ROLE `{new_role}` FOR `{mysql_user}`@`%`")

            conn.commit()
            logger.info(f"Consultant {target_id} updated by {caller_id} (role_changed={role_changed})")

            return jsonify({"success": True, "IdConsultant": target_id, "roleChanged": role_changed})

        # ----- INSERT path -----
        cursor.execute("SELECT IFNULL(MAX(IdConsultant), 0) + 1 AS NextId FROM SVN_00.Consultanti")
        new_id = int(cursor.fetchone()["NextId"])
        new_k1 = generate_k1()

        cursor.execute(
            "INSERT INTO SVN_00.Consultanti (IdConsultant, NumeConsultant, cTelefon, cMail, "
            "IdParinte, IdNivel, Suffix, Nou, IdRegiune, K1, SchimbaParola) "
            "VALUES (%s, %s, %s, %s, %s, %s, 'C', 1, 1, %s, 1)",
            (new_id, nume, telefon, cmail, id_parinte, id_nivel, new_k1)
        )

        mysql_user = f"C{new_id:03d}"
        initial_password = secrets.token_urlsafe(24)
        escaped = initial_password.replace("\\", "\\\\").replace("'", "\\'")

        cursor.execute(
            f"CREATE USER `{mysql_user}`@`%` IDENTIFIED WITH mysql_native_password "
            f"BY '{escaped}' REQUIRE SSL"
        )
        cursor.execute(f"GRANT `{new_role}` TO `{mysql_user}`@`%`")
        cursor.execute(f"SET DEFAULT ROLE `{new_role}` FOR `{mysql_user}`@`%`")

        conn.commit()
        logger.info(f"Consultant {new_id} created by {caller_id} as {mysql_user}")

        # K1 is returned so the form can display it, but the account cannot be
        # used until the consultant sets a password through /change-password
        return jsonify({"success": True, "IdConsultant": new_id, "K1": new_k1})

    except MySQLError as e:
        if conn:
            try: conn.rollback()
            except Exception: pass
        logger.error(f"save_consultant MySQL error: {e}")
        return jsonify({"success": False, "message": "Operatiunea a esuat pe server!"}), 500

    except Exception as e:
        if conn:
            try: conn.rollback()
            except Exception: pass
        logger.error(f"save_consultant error: {e}")
        return jsonify({"success": False, "message": "Eroare tehnica la salvarea utilizatorului."}), 500

    finally:
        if cursor:
            try: cursor.close()
            except Exception: pass
        if conn:
            try: conn.close()
            except Exception: pass


@vba_bp.route("/regenerate-key", methods=["POST"])
@require_api_key
def regenerate_key():
    """Replaces Form_Utilizatori_Sub.bRef_Click.

    K1 is generated server-side and returned once so the form can show it.
    """
    conn = None
    cursor = None
    try:
        data = request.get_json(silent=True) or {}

        caller = authenticate_caller(data.get("callerEmail"), data.get("callerPassword"))
        if not caller:
            return jsonify({"success": False, "message": "Autentificare esuata."}), 401

        caller_id = int(caller["IdConsultant"])
        caller_level = int(caller["IdNivel"] or 0)

        try:
            target_id = int(data.get("IdConsultant"))
        except (TypeError, ValueError):
            return jsonify({"success": False, "message": "IdConsultant invalid."}), 400

        if not has_right(caller_id, 2):
            return jsonify({"success": False, "message": "Nu aveti dreptul de a modifica utilizatori!"}), 403

        if caller_level < 40 and not is_descendant(caller_id, target_id):
            return jsonify({"success": False, "message": "Puteti modifica doar utilizatorii din subordinea dumneavoastra!"}), 403

        new_k1 = generate_k1()

        conn = get_vba_conn()
        cursor = conn.cursor()
        set_audit_user(cursor, caller_id)
        cursor.execute(
            "UPDATE SVN_00.Consultanti SET K1 = %s WHERE IdConsultant = %s",
            (new_k1, target_id)
        )

        if cursor.rowcount != 1:
            conn.rollback()
            return jsonify({"success": False, "message": "Utilizatorul nu exista!"}), 404

        conn.commit()
        logger.info(f"K1 regenerated for {target_id} by {caller_id}")

        return jsonify({"success": True, "IdConsultant": target_id, "K1": new_k1})

    except Exception as e:
        if conn:
            try: conn.rollback()
            except Exception: pass
        logger.error(f"regenerate_key error: {e}")
        return jsonify({"success": False, "message": "Eroare tehnica la regenerarea cheii."}), 500

    finally:
        if cursor:
            try: cursor.close()
            except Exception: pass
        if conn:
            try: conn.close()
            except Exception: pass


@vba_bp.route("/send-key", methods=["POST"])
@require_api_key
def send_key():
    """Replaces Form_Utilizatori.TrimiteCheie and TrimiteCheie_Recursiv.

    K1 is read and mailed entirely server-side. With recursive = true the
    whole subtree below IdConsultant is processed as well.
    """
    try:
        data = request.get_json(silent=True) or {}

        caller = authenticate_caller(data.get("callerEmail"), data.get("callerPassword"))
        if not caller:
            return jsonify({"success": False, "message": "Autentificare esuata."}), 401

        caller_id = int(caller["IdConsultant"])
        caller_level = int(caller["IdNivel"] or 0)
        recursive = bool(data.get("recursive"))

        try:
            target_id = int(data.get("IdConsultant"))
        except (TypeError, ValueError):
            return jsonify({"success": False, "message": "IdConsultant invalid."}), 400

        if caller_level < 40 and not is_descendant(caller_id, target_id):
            return jsonify({"success": False, "message": "Puteti trimite cheia doar subordonatilor dumneavoastra!"}), 403

        # SetariADC lives in each department database, not in SVN_00
        department = str(data.get("department") or "").strip().upper()
        if department not in ("SVN_IM", "SVN_NP", "SVN_AS", "SVN_TEST"):
            return jsonify({"success": False, "message": "Baza de date invalida."}), 400

        template_row = db_query(
            f"SELECT Valoare FROM `{department}`.SetariADC WHERE Setare = 'DATE_USER'", one=True
        )
        if not template_row or not template_row.get("Valoare"):
            return jsonify({"success": False, "message": "Sablonul de email nu este configurat!"}), 500

        template = str(template_row["Valoare"])

        # Collect the target plus, when requested, every descendant
        targets = db_query(
            "SELECT IdConsultant, NumeConsultant, cMail, K1 FROM SVN_00.Consultanti "
            "WHERE IdConsultant = %s AND Plecat = 0 AND Ascuns = 0",
            (target_id,)
        )

        if recursive:
            pending = [target_id]
            seen = {target_id}
            for _ in range(20):  # depth guard against a corrupted parent chain
                if not pending:
                    break
                placeholders = ", ".join(["%s"] * len(pending))
                children = db_query(
                    f"SELECT IdConsultant, NumeConsultant, cMail, K1 FROM SVN_00.Consultanti "
                    f"WHERE IdParinte IN ({placeholders}) AND Plecat = 0 AND Ascuns = 0",
                    tuple(pending)
                )
                pending = []
                for child in children:
                    cid = int(child["IdConsultant"])
                    if cid not in seen:
                        seen.add(cid)
                        targets.append(child)
                        pending.append(cid)

        if not targets:
            return jsonify({"success": False, "message": "Nu am gasit niciun utilizator activ!"}), 404

        sent = 0
        errors = []

        for row in targets:
            name = str(row.get("NumeConsultant") or "")
            address = str(row.get("cMail") or "").strip()
            key = str(row.get("K1") or "")

            if not address:
                errors.append(f"{name} - Lipsa adresa mail!")
                continue
            if not key:
                errors.append(f"{name} - Lipsa cheie!")
                continue

            body = template.replace("[uname]", name).replace("[cheie]", key)

            if send_mail("Date conectare CRM AD.CREDIT", address, body):
                sent += 1
            else:
                errors.append(f"{name} - Mail netrimis!")

        logger.info(f"send_key by {caller_id} on {department}: {sent} sent, {len(errors)} errors")

        return jsonify({
            "success": len(errors) == 0,
            "sent": sent,
            "errors": errors,
            "message": "Cheile au fost trimise cu succes!" if not errors else "Au existat erori la trimitere.",
        })

    except Exception as e:
        logger.error(f"send_key error: {e}")
        return jsonify({"success": False, "message": "Eroare tehnica la trimiterea cheilor."}), 500