# ========== routes/auth.py ==========
from flask import (
    Blueprint,
    render_template,
    request,
    redirect,
    url_for,
    session,
    jsonify,
    current_app,
)
from modules.db import get_service_conn, get_user_conn
from datetime import datetime
from dotenv import load_dotenv
from typing import cast
import os
import time
import logging
import secrets
import base64
import io
import redis
import pyotp
import qrcode

from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from redis import Redis as SyncRedis
from urllib.parse import quote_plus

load_dotenv()

try:
    redis_client = SyncRedis(
        host=os.getenv("REDIS_HOST", "localhost"),
        port=int(os.getenv("REDIS_PORT", 6379)),
        db=int(os.getenv("REDIS_DB", 0)),
        password=os.getenv("REDIS_PASSWORD"),
        decode_responses=False,
    )

    # Testează conexiunea
    redis_client.ping()

except Exception as e:
    logging.getLogger("auth").error(f"Redis connection failed: {e}")

# Creează blueprint
auth_bp = Blueprint("auth", __name__)

duration = int(os.getenv("REDIS_BLOCK_DURATION", "3600"))

# Inițializează Flask-Limiter
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["100 per day", "20 per hour"],
    storage_uri=f"redis://:{quote_plus(os.getenv('REDIS_PASSWORD', ''))}@{os.getenv('REDIS_HOST', 'localhost')}:{os.getenv('REDIS_PORT', '6379')}/{os.getenv('REDIS_DB', '0')}",
)


# Contor pentru încercări eșuate
def increment_failed_attempts(email: str, ip: str) -> int:
    key = f"failed_attempts:{email}:{ip}"
    logging.getLogger("auth").debug(f"Creating Redis key: {key}")

    try:
        count = cast(int, redis_client.incr(key))
        logging.getLogger("auth").debug(f"Redis incr result: {count}")
        if count == 1:
            redis_client.expire(key, 3600)
            logging.getLogger("auth").debug(f"Set expiry for key: {key}")
        return count
    except Exception as e:
        logging.getLogger("auth").error(f"Redis error: {e}")
        return 0


def get_failed_attempts(email: str, ip: str) -> int:
    key = f"failed_attempts:{email}:{ip}"
    count = cast(int, redis_client.get(key))
    logging.getLogger("auth").info(
        f"🔍 Verificări eșuate pentru {email} din IP: {ip} - {count} încercări"
    )
    return int(count) if count else 0


def block_account(email: str, duration: int = duration):
    key = f"blocked_account:{email}"
    redis_client.setex(key, duration, "blocked")
    logging.getLogger("auth").info(
        f"🚨 Cont blocat temporar: {email} pentru {duration} secunde"
    )


def is_account_blocked(email: str) -> bool:
    key = f"blocked_account:{email}"
    return bool(redis_client.exists(key))


TABLE_PK_MAP: dict[str, str] = {}


@auth_bp.route("/login", methods=["GET", "POST"])
def login():
    """Pagina de login"""
    error = None
    if request.method == "POST":
        error = "Utilizați interfața JavaScript pentru login."
    return render_template("login.html", error=error)


@auth_bp.route("/admin/unlock", methods=["GET"])
def admin_unlock_page():
    """Afișează pagina de deblocare conturi"""
    logging.getLogger("auth").info(f"? Is user admin: {session.get('is_admin', False)}")
    if "user" not in session or not session.get("is_admin"):
        return redirect(url_for("auth.login"))
    return render_template("admin_unlock.html")


@auth_bp.route("/api/check-email", methods=["POST"])
@limiter.limit("5 per minute")  # Limitează cererile de verificare email
def api_check_email():
    """Verifică email și returnează bazele de date disponibile"""
    ip = cast(str, request.remote_addr)

    logging.getLogger("auth").info(
        f"🔍 Verific email și baze de date disponibile din IP: {ip}"
    )

    try:
        data = request.get_json()
        email = data.get("email", "").strip()

        if not email:
            return jsonify({"exists": False, "message": "Email lipsă"}), 400

        # Verifică dacă contul este blocat
        if is_account_blocked(email):
            logging.getLogger("auth").warning(f"🚨 Cont blocat: {email} din IP: {ip}")
            return (
                jsonify(
                    {
                        "exists": False,
                        "message": "Contul este blocat temporar. Încercați din nou mai târziu.",
                    }
                ),
                403,
            )

        admin_conn = get_service_conn()
        cursor = admin_conn.cursor()

        query = """
        SELECT IdConsultant, IdNivel, IdParinte, NumeConsultant, Parola_Resetata, BazePermise 
        FROM SVN_00.Consultanti 
        WHERE cMail = %s AND Ascuns=0 AND Plecat=0
        """
        cursor.execute(query, (email,))
        result = cursor.fetchone()

        cursor.close()
        admin_conn.close()

        if result:
            (
                IdConsultant,
                IdNivel,
                IdParinte,
                NumeConsultant,
                parola_resetata,
                baze_permise,
            ) = result

            database_map = {
                "1": "SVN_IM",
                "2": "SVN_NP",
                "3": "SVN_AS",
                "4": "SVN_TEST",
            }

            departmente_disponibile = []
            if baze_permise:
                allowed_db_ids = [
                    db_id.strip() for db_id in baze_permise.split(",") if db_id.strip()
                ]
                for db_id in allowed_db_ids:
                    if db_id in database_map:
                        departmente_disponibile.append(database_map[db_id])

            logging.getLogger("auth").info(f"✅ Email găsit: {email}")
            logging.getLogger("auth").info(
                f"🗄️ Baze de date disponibile: {departmente_disponibile}"
            )
            logging.getLogger("auth").info(f"🔐 Parola resetată: {parola_resetata}")

            # ✅ SALVARE ÎN SESIUNE
            session["user_email"] = email
            session["IdConsultant"] = IdConsultant
            session["IdNivel"] = IdNivel
            session["IdParinte"] = IdParinte
            session["NumeConsultant"] = NumeConsultant
            session["parola_resetata"] = parola_resetata
            session["baze_permise"] = baze_permise
            session["departmente_disponibile"] = departmente_disponibile

            # Marchează sesiunea ca modificată pentru a forța salvarea
            session.modified = True

            return jsonify(
                {
                    "exists": True,
                    "parola_resetata": parola_resetata,
                    "baze_permise": baze_permise,
                    "departmente_disponibile": departmente_disponibile,
                    "NumeConsultant": NumeConsultant,
                    "IdConsultant": IdConsultant,
                    "IdParinte": IdParinte,
                    "IdNivel": IdNivel,
                }
            )
        else:
            count = increment_failed_attempts(email, ip)
            logging.getLogger("auth").warning(
                f"❌ Email nu există: {email}, încercare {count} din IP: {ip}"
            )
            if int(count) >= 5:
                block_account(
                    email, duration=3600
                )  # Blochează contul 1 oră după 5 încercări
                return (
                    jsonify(
                        {
                            "exists": False,
                            "message": "Contul a fost blocat temporar din cauza prea multor încercări.",
                        }
                    ),
                    403,
                )
            return jsonify(
                {
                    "exists": False,
                    "parola_resetata": 0,
                    "baze_permise": "",
                    "departmente_disponibile": [],
                    "message": "Email-ul nu este înregistrat în sistem",
                }
            )

    except Exception as e:
        logging.getLogger("auth").error(f"💥 Eroare check email: {e}")
        return (
            jsonify(
                {"exists": False, "message": "Eroare tehnică la verificarea email-ului"}
            ),
            500,
        )


@auth_bp.route("/api/verify-k1", methods=["POST"])
def api_verify_k1():
    """Verifică K1 pentru parolă resetată + bază de date"""
    try:
        data = request.get_json()
        email = data.get("email", "").strip()
        k1 = data.get("k1", "").strip()
        department = data.get(
            "department", ""
        )  # Acum este numele bazei de date (ex: SVN_IM)

        if not email:
            return jsonify({"success": False, "message": "Email lipsă!"}), 400

        if not k1:
            return jsonify({"success": False, "message": "Introduceți codul K1!"}), 400

        if not department:
            return (
                jsonify({"success": False, "message": "Selectați serviciu!"}),
                400,
            )

        logging.getLogger("auth").info(
            f"🔑 Verific K1 pentru {email} în baza de date {department}"
        )

        admin_conn = get_service_conn()
        cursor = admin_conn.cursor()

        # Verifică în SVN_00 (baza principală)
        query = """
        SELECT K1, BazePermise, IdConsultant 
        FROM SVN_00.Consultanti 
        WHERE cMail = %s AND Parola_Resetata = 1 AND Ascuns=0 AND Plecat=0
        """
        cursor.execute(query, (email,))
        result = cursor.fetchone()

        if not result:
            cursor.close()
            admin_conn.close()
            return jsonify(
                {
                    "success": False,
                    "message": "Utilizatorul nu are parolă resetată sau contul este inactiv.",
                }
            )

        k1_database, baze_permise, IdConsultant = result

        # Verifică K1
        if k1 != k1_database:
            cursor.close()
            admin_conn.close()
            return jsonify(
                {"success": False, "message": "Cheia unică K1 este incorectă."}
            )

        # Verifică dacă baza de date selectată este permisă
        database_map = {
            "1": "SVN_IM",  # Ipotecare
            "2": "SVN_NP",  # Nevoi Personale
            "3": "SVN_AS",  # Asigurări
            "4": "SVN_TEST",  # Testing (pentru viitor)
        }

        allowed_db_ids = [
            db_id.strip() for db_id in baze_permise.split(",") if db_id.strip()
        ]
        allowed_databases = [
            database_map[db_id] for db_id in allowed_db_ids if db_id in database_map
        ]

        if department not in allowed_databases:
            cursor.close()
            admin_conn.close()
            return jsonify(
                {
                    "success": False,
                    "message": f"Nu aveți acces la baza de date {department}.",
                }
            )

        # K1 și baza de date corecte - salvează în sesiune
        session["user"] = email
        session["department"] = department  # Salvează numele bazei de date (ex: SVN_IM)
        session["force_password_change"] = True
        session["IdConsultant"] = IdConsultant

        cursor.close()
        admin_conn.close()

        logging.getLogger("auth").info(
            f"✅ K1 și baza de date corecte pentru {email} în {department}"
        )

        return jsonify(
            {
                "success": True,
                "message": "Verificare reușită! Redirectare către schimbarea parolei...",
                "redirect": url_for("auth.force_password_change"),
            }
        )

    except Exception as e:
        logging.getLogger("auth").info(f"💥 Eroare verificare K1: {e}")
        return (
            jsonify(
                {
                    "success": False,
                    "message": "Eroare tehnică la verificarea codului K1.",
                }
            ),
            500,
        )


@auth_bp.route("/api/login", methods=["POST"])
@limiter.limit("5 per minute")  # Limitează cererile de login
def api_login():
    """Login normal cu verificare bază de date"""
    ip = request.remote_addr
    logging.getLogger("auth").info(f"🔐 Încercare login din IP: {ip}")

    try:
        data = request.get_json() or {}
        email = data.get("email", "").strip()
        password = data.get("password", "")
        department = data.get("department", "")

        logging.getLogger("auth").debug(f"Email: {email}, Departament: {department}")

        if not email:
            return jsonify({"success": False, "message": "Introduceți email-ul!"}), 400
        if not password:
            return jsonify({"success": False, "message": "Introduceți parola!"}), 400
        if not department:
            return jsonify({"success": False, "message": "Selectați serviciu!"}), 400

        # Verifică dacă contul este blocat
        if is_account_blocked(email):
            logging.getLogger("auth").warning(f"🚨 Cont blocat: {email} din IP: {ip}")
            return (
                jsonify(
                    {
                        "success": False,
                        "message": "Contul este blocat temporar. Încercați din nou mai târziu.",
                    }
                ),
                403,
            )

        # Adaugă întârziere progresivă bazată pe încercări eșuate
        failed_attempts = get_failed_attempts(email, cast(str, ip))
        if failed_attempts > 0:
            time.sleep(min(failed_attempts * 0.5, 5))  # Întârziere max 5 secunde

        admin_conn = get_service_conn()
        cursor = admin_conn.cursor()

        query = """
        SELECT IdConsultant, IdParinte, IdNivel, NumeConsultant, BazePermise, Parola_Resetata, Ascuns
        FROM SVN_00.Consultanti 
        WHERE cMail = %s
        """
        cursor.execute(query, (email,))
        result = cursor.fetchone()

        if not result:
            logging.getLogger("auth").info(
                f"🔍 [DEBUG] User not found, calling increment_failed_attempts"
            )
            count = increment_failed_attempts(email, cast(str, ip))
            logging.getLogger("auth").warning(
                f"❌ Email incorect: {email}, încercare {count} din IP: {ip}"
            )
            if count >= 5:
                block_account(email, duration=3600)
                return (
                    jsonify(
                        {
                            "success": False,
                            "message": "Contul a fost blocat temporar din cauza prea multor încercări.",
                        }
                    ),
                    403,
                )
            return jsonify({"success": False, "message": "Email incorect."}), 401

        (
            IdConsultant,
            IdParinte,
            IdNivel,
            NumeConsultant,
            baze_permise,
            parola_resetata,
            ascuns,
        ) = result

        if ascuns:
            cursor.close()
            admin_conn.close()
            return (
                jsonify(
                    {
                        "success": False,
                        "message": "Contul este dezactivat. Contactați administratorul.",
                    }
                ),
                401,
            )

        database_map = {
            "1": "SVN_IM",
            "2": "SVN_NP",
            "3": "SVN_AS",
            "4": "SVN_TEST",
        }

        allowed_db_ids = [
            db_id.strip() for db_id in baze_permise.split(",") if db_id.strip()
        ]
        allowed_databases = [
            database_map[db_id] for db_id in allowed_db_ids if db_id in database_map
        ]

        # ===== CALE SPECIALĂ: ADMINISTRARE cu TOTP =====
        if department == "ADMIN":
            if IdNivel < 40:
                count = increment_failed_attempts(email, cast(str, ip))
                if count >= 5:
                    block_account(email, duration=3600)
                    return jsonify({"success": False, "message": "Cont blocat temporar."}), 403
                return jsonify({"success": False, "message": "Nu aveți permisiuni de administrare."}), 401

            if parola_resetata == 1:
                cursor.close()
                admin_conn.close()
                return jsonify({
                    "success": False,
                    "message": "Parola a fost resetată. Folosiți codul K1 pentru a o schimba.",
                    "redirect": url_for("auth.show_reset_password_page"),
                }), 401

            # Citește secretul TOTP din DB
            cursor.execute(
                "SELECT TotpSecret FROM SVN_00.Consultanti WHERE IdConsultant = %s",
                (IdConsultant,)
            )
            totp_row = cursor.fetchone()
            totp_secret = totp_row[0] if totp_row else None
            cursor.close()
            admin_conn.close()

            # Verifică parola prin conexiunea MySQL
            try:
                user_conn = get_user_conn(email, password)
                user_conn.close()
            except Exception:
                count = increment_failed_attempts(email, cast(str, ip))
                if count >= 5:
                    block_account(email, duration=3600)
                    return jsonify({"success": False, "message": "Cont blocat temporar."}), 403
                return jsonify({"success": False, "message": "Parolă incorectă."}), 401

            # Stochează datele în sesiune pentru pasul 2
            session["admin_2fa_email"] = email
            session["admin_2fa_id"] = IdConsultant
            session["admin_2fa_name"] = NumeConsultant
            session.modified = True

            if not totp_secret:
                # Prima dată — generează secret și returnează QR code pentru setup
                new_secret = pyotp.random_base32()
                session["admin_totp_setup_secret"] = new_secret
                session.modified = True

                totp_uri = pyotp.totp.TOTP(new_secret).provisioning_uri(
                    name=email,
                    issuer_name="AD.CREDIT Admin"
                )
                # Generează QR code ca imagine base64
                img = qrcode.make(totp_uri)
                buf = io.BytesIO()
                img.save(buf, format="PNG")
                qr_b64 = base64.b64encode(buf.getvalue()).decode()

                logging.getLogger("auth").info(f"🔐 TOTP setup inițiat pentru {email}")
                return jsonify({
                    "success": True,
                    "requires_totp_setup": True,
                    "qr_b64": qr_b64,
                    "secret": new_secret,
                })
            else:
                # Secret există — cere codul din aplicație
                logging.getLogger("auth").info(f"🔐 TOTP verificare inițiată pentru {email}")
                return jsonify({
                    "success": True,
                    "requires_2fa": True,
                })

        if department == "ADMIN":
            # Fallback de siguranță - ADMIN trebuia tratat mai sus; reluăm fluxul
            logging.getLogger("auth").error(
                f"⚠️ ADMIN fallthrough neașteptat pentru {email} (IdNivel={IdNivel})"
            )
            if IdNivel >= 40:
                session["admin_2fa_email"] = email
                session["admin_2fa_id"]    = IdConsultant
                session["admin_2fa_name"]  = NumeConsultant
                session.modified = True
                return jsonify({"success": True, "requires_2fa": True})
            return jsonify({"success": False, "message": "Nu aveți permisiuni de administrare."}), 401

        if department not in allowed_databases:
            count = increment_failed_attempts(email, cast(str, ip))
            logging.getLogger("auth").warning(
                f"❌ Acces neautorizat la baza {department}, încercare {count} din IP: {ip}"
            )
            if count >= 5:
                block_account(email, duration=3600)
                return (
                    jsonify(
                        {
                            "success": False,
                            "message": "Contul a fost blocat temporar din cauza prea multor încercări.",
                        }
                    ),
                    403,
                )
            return (
                jsonify(
                    {
                        "success": False,
                        "message": f"Nu aveți acces la baza de date {department}.",
                    }
                ),
                401,
            )

        if parola_resetata == 1:
            cursor.close()
            admin_conn.close()
            return (
                jsonify(
                    {
                        "success": False,
                        "message": "Parola a fost resetată. Folosiți codul K1 pentru a o schimba.",
                        "parola_resetata": True,
                        "redirect": url_for("auth.show_reset_password_page"),
                    }
                ),
                401,
            )

        cursor.close()
        admin_conn.close()

        try:
            user_conn = get_user_conn(email, password)
            user_conn.close()
            logging.getLogger("auth").info(
                f"✅ Autentificare MySQL reușită pentru {email}"
            )
        except Exception as auth_error:
            count = increment_failed_attempts(email, cast(str, ip))
            logging.getLogger("auth").warning(
                f"❌ Parolă incorectă: {email}, încercare {count} din IP: {ip}"
            )
            if count >= 5:
                block_account(email, duration=3600)
                return (
                    jsonify(
                        {
                            "success": False,
                            "message": "Contul a fost blocat temporar din cauza prea multor încercări.",
                        }
                    ),
                    403,
                )
            return jsonify({"success": False, "message": "Parolă incorectă."}), 401

        session["user"] = email
        session["NumeConsultant"] = NumeConsultant
        session["IdParinte"] = IdParinte
        session["IdNivel"] = IdNivel
        session["department"] = department
        session["IdConsultant"] = IdConsultant
        session["is_admin"] = IdNivel >= 40
        session.permanent = True

        timeout_minutes = int(os.getenv("SESSION_TIMEOUT", "10"))
        current_time = time.time()

        session["session_created"] = current_time
        session["session_expires_at"] = current_time + (timeout_minutes * 60)
        session["last_real_activity"] = current_time

        try:
            conn = get_user_conn(
                email, password
            )  # o redeschizi (sau refolosești user_conn)
            cur = conn.cursor()  # fără dictionary=True
            cur.execute(
                """
                SELECT TABLE_NAME, COLUMN_NAME
                FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
                WHERE TABLE_SCHEMA = %s
                AND CONSTRAINT_NAME = 'PRIMARY'
            """,
                (department,),
            )

            TABLE_PK_MAP.clear()
            for table_name, pk_column in cur.fetchall():
                TABLE_PK_MAP[str(table_name)] = str(pk_column)

        except Exception as exc:
            logging.getLogger("auth").error("Eroare la citirea PK-urilor: %s", exc)

        logging.getLogger("auth").info(
            f"✅ Login complet reușit pentru {email} în baza de date {department}"
        )
        logging.getLogger("auth").info(
            f"Timeout minutes: {timeout_minutes}; session['session_created']: {current_time}; session['session_expires_at']: {session['session_expires_at']}"
        )

        # Resetează contorul de încercări eșuate la login reușit
        redis_client.delete(f"failed_attempts:{email}:{ip}")

        return jsonify(
            {
                "success": True,
                "message": "Autentificare reușită!",
                "redirect": url_for("dashboard.index"),
            }
        )

    except Exception as e:
        logging.getLogger("auth").error(f"💥 Eroare login: {e}")
        return (
            jsonify({"success": False, "message": "Eroare tehnică la autentificare."}),
            500,
        )


@auth_bp.route("/verify-admin-totp", methods=["POST"])
@limiter.limit("10 per minute")
def api_verify_admin_2fa():
    """Verifică codul TOTP și creează sesiunea de admin.
    Dacă este primul login (setup), salvează secretul în DB."""
    ip = request.remote_addr

    try:
        data = request.get_json() or {}
        code = data.get("code", "").strip()

        email = session.get("admin_2fa_email")
        if not email:
            return jsonify({"success": False, "message": "Sesiune expirată. Reîncercați login-ul."}), 400

        IdConsultant_int = session.get("admin_2fa_id")
        db_name          = session.get("admin_2fa_name")
        setup_secret     = session.get("admin_totp_setup_secret")  # prezent doar la setup

        # Determină secretul TOTP de folosit
        if setup_secret:
            totp_secret = setup_secret
        else:
            # Citește din DB
            svc = get_service_conn()
            cur = svc.cursor()
            cur.execute(
                "SELECT TotpSecret FROM SVN_00.Consultanti WHERE IdConsultant = %s",
                (IdConsultant_int,)
            )
            row = cur.fetchone()
            cur.close()
            svc.close()
            totp_secret = row[0] if row and row[0] else None

        if not totp_secret:
            return jsonify({"success": False, "message": "Secretul TOTP nu a fost găsit. Reîncercați login-ul."}), 400

        # Verifică codul TOTP (valid_window=1 = acceptă codul anterior/curent/următor)
        totp = pyotp.TOTP(totp_secret)
        if not totp.verify(code, valid_window=1):
            return jsonify({"success": False, "message": "Cod incorect sau expirat. Încercați din nou."}), 401

        # Cod corect — dacă e setup, salvează secretul în DB
        if setup_secret:
            svc = get_service_conn()
            cur = svc.cursor()
            cur.execute(
                "UPDATE SVN_00.Consultanti SET TotpSecret = %s WHERE IdConsultant = %s",
                (totp_secret, IdConsultant_int)
            )
            svc.commit()
            cur.close()
            svc.close()
            session.pop("admin_totp_setup_secret", None)
            logging.getLogger("auth").info(f"✅ TOTP secret salvat pentru {email}")

        # Curăță sesiunea temporară
        session.pop("admin_2fa_email", None)
        session.pop("admin_2fa_id",    None)
        session.pop("admin_2fa_name",  None)

        # Construiește sesiunea de admin (același pattern ca admin_auth.py)
        username = f"C{IdConsultant_int:03d}"
        current_time = time.time()
        timeout_minutes = int(os.getenv("SESSION_TIMEOUT", "15"))
        session["admin_user"]               = email
        session["admin_username"]           = username
        session["admin_name"]               = db_name
        session["admin_id"]                 = IdConsultant_int
        session["is_super_admin"]           = True
        session["admin_login_time"]         = current_time
        session["admin_session_expires_at"] = current_time + (timeout_minutes * 60)
        session["admin_last_activity"]      = current_time
        session["admin_extension_count"]    = 0
        session["IdConsultant"]             = IdConsultant_int
        session.permanent = True
        session.modified  = True

        redis_client.delete(f"failed_attempts:{email}:{ip}")
        logging.getLogger("auth").info(f"✅ Admin autentificat via TOTP: {email}")

        return jsonify({
            "success": True,
            "message": f"Bun venit, {db_name}!",
            "redirect": "/admin/dashboard",
        })

    except Exception as e:
        logging.getLogger("auth").error(f"💥 Eroare verify-admin-2fa: {e}")
        return jsonify({"success": False, "message": "Eroare tehnică."}), 500


@auth_bp.route("/reset-password", methods=["GET", "POST"])
def show_reset_password_page():
    """AFIȘEAZĂ pagina de resetare parolă (formularul HTML)"""
    message = None
    error = None

    logging.getLogger("auth").info("=== AFIȘEZ PAGINA DE RESETARE ===")

    if request.method == "POST":
        logging.getLogger("auth").info("=== FORMULAR TRIMIS DIRECT ===")
        email = request.form["email"]
        k1 = request.form.get("k1") or ""

    return render_template("reset_password.html", message=message, error=error)


@auth_bp.route("/api/reset-password", methods=["POST"])
def check_reset_password_data():
    """VERIFICĂ datele de resetare în baza de date și răspunde cu JSON"""
    try:
        data = request.get_json()
        email = data.get("email", "").strip()
        k1 = data.get("k1", "").strip()

        logging.getLogger("auth").info(f"🔍 VERIFIC RESETARE PENTRU: {email}")

        admin_conn = get_service_conn()
        cursor = admin_conn.cursor()

        query = "SELECT IdConsultant, K1 FROM SVN_00.Consultanti WHERE cMail = %s"
        cursor.execute(query, (email,))
        result = cursor.fetchone()

        if not result:
            logging.getLogger("auth").info(f"❌ Email '{email}' NU EXISTĂ în sistem")
            cursor.close()
            admin_conn.close()
            return jsonify(
                {
                    "success": False,
                    "message": "Adresa de email nu este înregistrată în sistem.",
                }
            )

        IdConsultant = result[0]
        k1_from_database = result[1]

        logging.getLogger("auth").info(f"✅ Email GĂSIT! IdConsultant = {IdConsultant}")

        if k1 != k1_from_database:
            logging.getLogger("auth").info(
                f"❌ K1 GREȘIT: introdus='{k1}' vs database='{k1_from_database}'"
            )
            cursor.close()
            admin_conn.close()
            return jsonify(
                {"success": False, "message": "Codul de securitate K1 este incorect."}
            )

        logging.getLogger("auth").info("✅ K1 este CORECT!")

        cursor.execute(
            "UPDATE SVN_00.Consultanti SET Parola_Resetata = 1 WHERE cMail = %s",
            (email,),
        )
        admin_conn.commit()

        logging.getLogger("auth").info("✅ Flag de resetare ACTUALIZAT în baza de date")

        cursor.close()
        admin_conn.close()

        return jsonify(
            {
                "success": True,
                "message": "Cererea de resetare a fost aprobată! Veți fi contactat în curând pentru noua parolă.",
            }
        )

    except Exception as e:
        logging.getLogger("auth").info(f"💥 EROARE la verificarea resetării: {e}")
        return (
            jsonify(
                {
                    "success": False,
                    "message": "A apărut o eroare tehnică. Contactați administratorul.",
                }
            ),
            500,
        )


@auth_bp.route("/force-password-change", methods=["GET", "POST"])
def force_password_change():
    """FORȚEAZĂ utilizatorul să își schimbe parola"""
    if "user" not in session or "force_password_change" not in session:
        return redirect(url_for("auth.login"))

    error = None
    message = None

    if request.method == "POST":
        new_password = request.form["new_password"]
        confirm_password = request.form["confirm_password"]

        logging.getLogger("auth").info(
            f"🔐 Utilizatorul {session['user']} încearcă să își schimbe parola"
        )

        # Validări pentru noua parolă
        if len(new_password) < 10:
            error = "Parola trebuie să aibă minim 10 caractere."
        elif new_password != confirm_password:
            error = "Parolele nu se potrivesc."
        elif not any(c.isdigit() for c in new_password):
            error = "Parola trebuie să conțină cel puțin o cifră."
        elif not any(c.isalpha() for c in new_password):
            error = "Parola trebuie să conțină cel puțin o literă."
        elif not any(c in "!@#$%^&*()_+-=[]{}|;:,.<>?" for c in new_password):
            error = "Parola trebuie să conțină cel puțin un caracter special (!@#$%^&* etc.)."
        else:
            try:
                email = session["user"]

                admin_conn = get_service_conn()
                cursor = admin_conn.cursor()

                query = "SELECT IdConsultant FROM SVN_00.Consultanti WHERE cMail = %s"
                cursor.execute(query, (email,))
                result = cursor.fetchone()

                if result:
                    IdConsultant = result[0]
                    username = f"C{IdConsultant:03d}"

                    logging.getLogger("auth").info(
                        f"🔑 Schimb parola pentru utilizatorul MySQL: {username}"
                    )

                    cursor.execute(
                        f"ALTER USER '{username}'@'%' IDENTIFIED BY %s",
                        (new_password,),
                    )

                    cursor.execute(
                        "UPDATE SVN_00.Consultanti SET Parola_Resetata = 0 WHERE cMail = %s",
                        (email,),
                    )
                    admin_conn.commit()

                    logging.getLogger("auth").info("✅ Parola schimbată cu succes!")

                    session.pop("force_password_change", None)

                    cursor.close()
                    admin_conn.close()

                    return redirect(url_for("dashboard.index"))
                else:
                    error = "Nu găsesc utilizatorul în sistem."

            except Exception as e:
                logging.getLogger("auth").info(f"💥 Eroare la schimbarea parolei: {e}")
                error = "Eroare la schimbarea parolei. Încercați din nou."

    return render_template("force_password_change.html", error=error, message=message)


@auth_bp.route("/logout")
def logout():
    """Deconectare"""
    session.clear()
    return redirect(url_for("auth.login"))


@auth_bp.route("/api/debug-users", methods=["POST"])
def api_debug_users():
    """Debug: Verifică utilizatorii MySQL"""
    cursor = None
    admin_conn = None

    try:
        data = request.get_json()
        email = data.get("email")

        if not email:
            return jsonify({"success": False, "message": "Email lipsă"})

        admin_conn = get_service_conn()
        cursor = admin_conn.cursor()

        query = "SELECT IdConsultant FROM SVN_00.Consultanti WHERE cMail = %s"
        cursor.execute(query, (email,))
        result = cursor.fetchone()

        if not result:
            return jsonify(
                {"success": False, "message": "Email nu există în Consultanti"}
            )

        IdConsultant = result[0]
        username = f"C{IdConsultant:03d}"

        logging.getLogger("auth").info(f"🔍 Verific utilizatorul MySQL: {username}")

        cursor.execute("SELECT User, Host FROM mysql.user WHERE User = %s", (username,))
        mysql_users = cursor.fetchall()

        if mysql_users:
            logging.getLogger("auth").info(
                f"✅ Utilizatorul {username} EXISTĂ în MySQL:"
            )
            for user in mysql_users:
                logging.getLogger("auth").info(f"   User: {user[0]}, Host: {user[1]}")

            return jsonify(
                {
                    "success": True,
                    "message": f"Utilizatorul {username} există",
                    "mysql_users": [{"user": u[0], "host": u[1]} for u in mysql_users],
                }
            )
        else:
            logging.getLogger("auth").info(
                f"❌ Utilizatorul {username} NU EXISTĂ în MySQL"
            )
            return jsonify(
                {
                    "success": False,
                    "message": f"Utilizatorul {username} nu există în MySQL",
                }
            )

    except Exception as e:
        logging.getLogger("auth").info(f"💥 Eroare la debugging utilizatori: {e}")
        return jsonify({"success": False, "message": f"Eroare: {str(e)}"})

    finally:
        if cursor is not None:
            cursor.close()
        if admin_conn is not None:
            admin_conn.close()


@auth_bp.route("/api/session-info", methods=["GET"])
def get_init_session_info():
    """
    📊 Returnează informații inițiale despre sesiune
    Folosit O SINGURĂ DATĂ la încărcarea dashboard-ului
    """
    if "user" not in session:
        return (
            jsonify(
                {
                    "success": False,
                    "authenticated": False,
                    "message": "No active session",
                }
            ),
            401,
        )

    try:
        # Returnează doar informațiile esențiale
        timeout_minutes = int(os.getenv("SESSION_TIMEOUT", "10"))

        return (
            jsonify(
                {
                    "success": True,
                    "authenticated": True,
                    "user": session["user"],
                    "department": session["department"],
                    "IdConsultant": session["IdConsultant"],
                    "IsAdmin": session["is_admin"],
                    "session_data": {
                        "timeout_minutes": timeout_minutes,
                        "warning_before": 1,  # minute înainte de expirare pentru warning
                    },
                }
            ),
            200,
        )

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@auth_bp.route("/api/session-check", methods=["GET"])
def check_session():
    """
    🔐 Verifică validitatea sesiunii curente
    Returnează și informații despre timeout
    """
    user_data = None
    try:
        # Verifică dacă utilizatorul este autentificat
        if "user" not in session:
            logging.getLogger("auth").info(
                "🚨 Sesiune inactivă - utilizatorul nu este autentificat"
            )
            return (
                jsonify(
                    {
                        "success": False,
                        "authenticated": False,
                        "message": "No active session",
                    }
                ),
                401,
            )

        # Verifică dacă departmentul există în sesiune
        if "department" not in session:
            logging.getLogger("auth").info("🚨 Sesiune incompletă - lipsă department")
            return (
                jsonify(
                    {
                        "success": False,
                        "authenticated": True,
                        "message": "Session incomplete - missing department",
                        "user": session.get("user"),
                    }
                ),
                400,
            )

        # Verifică în baza de date dacă utilizatorul încă există și este activ
        from modules.db import get_service_conn

        conn = get_service_conn()
        cursor = conn.cursor()

        check_user_query = """
        SELECT cMail, NumeConsultant, BazePermise
        FROM SVN_00.Consultanti
        WHERE cMail = %s AND Ascuns=0 AND Plecat=0
        """

        cursor.execute(check_user_query, (session["user"],))
        user_data = cursor.fetchone()

        cursor.close()
        conn.close()

        if not user_data:
            # Utilizatorul nu mai există sau este inactiv
            logging.getLogger("auth").info(
                f"🚨 Utilizatorul {session['user']} nu mai există sau este inactiv"
            )
            session.clear()
            return (
                jsonify(
                    {
                        "success": False,
                        "authenticated": False,
                        "message": "User no longer exists or is inactive",
                    }
                ),
                401,
            )

        # Calculează timpul rămas până la expirare
        from datetime import datetime, timedelta
        import time

        # Obține timeout-ul din configurație (în minute)
        timeout_minutes = int(os.getenv("SESSION_TIMEOUT", "10"))

        # Calculează timpul rămas (aproximativ - Flask nu expune exact când expiră)
        # Presupunem că sesiunea a fost reînnoită la ultima activitate
        if session.permanent:
            # Estimează timpul rămas bazat pe configurație
            # Aceasta este o estimare - Flask nu oferă timp exact de expirare
            expires_in = timeout_minutes * 60  # în secunde

            # Dacă există un timestamp de ultima activitate în sesiune
            if "last_activity" in session:
                elapsed = time.time() - session["last_activity"]
                expires_in = max(0, (timeout_minutes * 60) - elapsed)

            # Actualizează timestamp-ul de activitate
            session["last_activity"] = time.time()
            session.modified = True  # Forțează Flask să salveze sesiunea
        else:
            expires_in = None

        # Sesiunea este validă - returnează datele
        return (
            jsonify(
                {
                    "success": True,
                    "authenticated": True,
                    "user": session["user"],
                    "department": session["department"],
                    "user_info": {
                        "email": user_data[0],  # cMail
                        "nume": user_data[1],  # NumeConsultant
                        "baze_permise": user_data[2],  # BazePermise
                        "department": session["department"],
                    },
                    "session_data": {
                        "created": session.get("session_created"),
                        "last_activity": session.get("last_activity", time.time()),
                        "permanent": session.permanent,
                        "timeout_minutes": timeout_minutes,
                        "expires_in": expires_in,  # secunde până la expirare
                    },
                }
            ),
            200,
        )

    except Exception as e:
        logging.getLogger("auth").info(f"🚨 EROARE la verificarea sesiunii: {str(e)}")
        return (
            jsonify(
                {
                    "success": False,
                    "authenticated": False,
                    "error": "Session validation failed",
                    "message": str(e),
                }
            ),
            500,
        )


@auth_bp.route("/api/extend-session", methods=["POST"])
def extend_session():
    """
    Endpoint dedicat pentru prelungirea sesiunii
    """
    if "user" not in session:
        return jsonify({"success": False, "message": "No active session"}), 401

    # Resetează timpul de expirare
    timeout_minutes = int(os.getenv("SESSION_TIMEOUT", "10"))
    current_time = time.time()

    logging.getLogger("auth").info(f"Timeout minutes: {timeout_minutes}")

    session["session_expires_at"] = current_time + (timeout_minutes * 60)
    session["last_real_activity"] = current_time
    session.modified = True

    logging.getLogger("auth").info(
        f"check_session: timeout_minutes: {timeout_minutes}; [session['session_created']: {current_time}; session['session_expires_at']: {session['session_expires_at']}"
    )

    return (
        jsonify(
            {
                "success": True,
                "message": "Session extended",
                "new_expires_in": timeout_minutes * 60,
            }
        ),
        200,
    )


@auth_bp.route("/api/force-logout", methods=["POST"])
def force_logout():
    """
    🚪 Logout forțat cu ștergere completă sesiune
    Folosit când se detectează inconsistențe
    """
    try:
        # Salvează informații pentru logging
        user = session.get("user", "unknown")

        # Curăță sesiunea complet
        session.clear()
        session.permanent = False

        logging.getLogger("auth").info(
            f"🚪 FORCE LOGOUT: Utilizatorul {user} a fost delogat forțat"
        )

        return (
            jsonify(
                {
                    "success": True,
                    "message": "Logged out successfully",
                    "redirect": "/login",
                }
            ),
            200,
        )

    except Exception as e:
        logging.getLogger("auth").info(f"🚨 EROARE la logout forțat: {str(e)}")
        return (
            jsonify({"success": False, "error": "Logout failed", "message": str(e)}),
            500,
        )


@auth_bp.route("/api/session-info", methods=["GET"])
def get_session_info():
    """
    📊 Informații detaliate despre sesiune (pentru debugging)
    """
    if not current_app.debug:
        return jsonify({"error": "Available only in debug mode"}), 403

    try:
        return (
            jsonify(
                {
                    "session_data": dict(session),
                    "session_permanent": session.permanent,
                    "authenticated": "user" in session,
                    "request_info": {
                        "remote_addr": request.remote_addr,
                        "user_agent": str(request.user_agent),
                        "method": request.method,
                        "path": request.path,
                    },
                    "cookies": dict(request.cookies),
                    "timestamp": datetime.now().isoformat(),
                }
            ),
            200,
        )

    except Exception as e:
        return jsonify({"error": "Failed to get session info", "message": str(e)}), 500


# ========== FUNCȚIE HELPER PENTRU VALIDAREA BAZEI DE DATE ==========
def validate_database_access(email, requested_database):
    """
    Validează dacă utilizatorul are acces la baza de date cerută

    Args:
        email (str): Email-ul utilizatorului
        requested_database (str): Numele bazei de date cerute (ex: SVN_IM)

    Returns:
        tuple: (bool, str) - (are_acces, mesaj_eroare)
    """
    try:
        admin_conn = get_service_conn()
        cursor = admin_conn.cursor()

        query = "SELECT BazePermise FROM SVN_00.Consultanti WHERE cMail = %s AND Ascuns = 0 AND Plecat = 0"
        cursor.execute(query, (email,))
        result = cursor.fetchone()

        cursor.close()
        admin_conn.close()

        if not result:
            return False, "Utilizatorul nu există sau este inactiv"

        database_map = {
            "1": "SVN_IM",  # Ipotecare
            "2": "SVN_NP",  # Nevoi Personale
            "3": "SVN_AS",  # Asigurări
            "4": "SVN_TEST",  # Testing (pentru viitor)
        }

        allowed_db_ids = [
            db_id.strip() for db_id in result[0].split(",") if db_id.strip()
        ]
        allowed_databases = [
            database_map[db_id] for db_id in allowed_db_ids if db_id in database_map
        ]

        if requested_database in allowed_databases:
            return True, ""
        else:
            return False, f"Nu aveți acces la baza de date {requested_database}"

    except Exception as e:
        logging.getLogger("auth").info(f"💥 Eroare validare bază de date: {e}")
        return False, "Eroare tehnică la validarea accesului"


# ========== EXEMPLU DE FOLOSIRE ÎN DASHBOARD ==========
def exemplu_query_cu_department():
    """
    Exemplu de cum se folosește variabila department în query-uri
    """
    department = session.get("department")  # Ex: "SVN_IM"

    # Query-ul va fi: SELECT * FROM SVN_IM.Consultanti
    query = f"SELECT * FROM {department}.Consultanti"

    # Query pentru tabele specifice
    query_dosare = f"SELECT Count(*) FROM {department}.Dosar WHERE Ascuns = 0"

    logging.getLogger("auth").info(f"Query consultanti: {query}")
    logging.getLogger("auth").info(f"Query dosare: {query_dosare}")

    return query
