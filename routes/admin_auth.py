# ========== routes/admin_auth.py ==========
"""
🛡️ ADMIN AUTHENTICATION MODULE
Autentificare și securitate pentru administratori
"""

# La ÎNCEPUTUL fișierului app.py
from dotenv import load_dotenv
import os

# PRIMUL lucru - încarcă .env
load_dotenv()

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
from datetime import datetime, timedelta
from typing import cast
import time
import logging
import redis

import mysql.connector
from mysql.connector import Error as MySQLError

from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

# Creează blueprint admin
admin_auth_bp = Blueprint("admin_auth", __name__, url_prefix="/admin")

# Redis client pentru admin (poate fi același ca la auth normal)
redis_client: redis.Redis = redis.Redis(
    host=os.getenv("REDIS_HOST", "localhost"),
    port=int(os.getenv("REDIS_PORT", 6379)),
    db=int(os.getenv("REDIS_DB", 0)),
    password=os.getenv("REDIS_PASSWORD"),
    decode_responses=True,
)

# Limiter pentru admin (mai restrictiv)
admin_limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["10 per day", "3 per hour"],  # Mai strict pentru admin
    storage_uri=f"redis://:{os.getenv('REDIS_PASSWORD')}@{os.getenv('REDIS_HOST')}:{os.getenv('REDIS_PORT')}/{os.getenv('REDIS_DB')}",
)


# ========== FUNCȚII REDIS PENTRU ADMIN ==========


def increment_failed_admin_attempts(email: str, ip: str) -> int:
    """Contorizează încercările eșuate admin - mai strict"""
    key = f"failed_admin_attempts:{email}:{ip}"
    count = cast(int, redis_client.incr(key))
    if count == 1:
        redis_client.expire(key, 1800)  # 30 min expirare pentru admin
    logging.getLogger("admin_auth").warning(
        f"🔥 Admin încercare eșuată {count} pentru {email} din {ip}"
    )
    return count


def get_failed_admin_attempts(email: str, ip: str) -> int:
    """Obține numărul de încercări eșuate admin"""
    key = f"failed_admin_attempts:{email}:{ip}"
    count = cast(int, redis_client.get(key))
    return int(count) if count else 0


def block_admin_account(email: str, duration: int = 7200):  # 2 ore default
    """Blochează contul admin pentru o durată mai lungă"""
    key = f"blocked_admin:{email}"
    redis_client.setex(key, duration, "blocked")
    logging.getLogger("admin_auth").error(
        f"🚨🚨 CONT ADMIN BLOCAT: {email} pentru {duration} secunde"
    )


def is_admin_blocked(email: str) -> bool:
    """Verifică dacă admin-ul este blocat"""
    key = f"blocked_admin:{email}"
    return bool(redis_client.exists(key))


def clear_admin_attempts(email: str, ip: str):
    """Șterge contoarele admin la login reușit"""
    redis_client.delete(f"failed_admin_attempts:{email}:{ip}")
    logging.getLogger("admin_auth").info(f"✅ Contoare admin resetate pentru {email}")


def get_admin_block_info(email: str) -> dict:
    """Returnează informații despre blocarea admin"""
    key = f"blocked_admin:{email}"
    if redis_client.exists(key):
        ttl = cast(int, redis_client.ttl(key))
        return {
            "blocked": True,
            "remaining_seconds": ttl,
            "remaining_minutes": round(ttl / 60, 1) if ttl > 0 else 0,
        }
    return {"blocked": False}


# ========== ROUTE HANDLERS ==========


@admin_auth_bp.route("/")
@admin_auth_bp.route("/login")
def admin_login():
    """Pagina specială de login pentru admin"""
    # Dacă este deja logat ca admin, redirecționează la dashboard
    if session.get("is_super_admin"):
        return redirect(url_for("admin_dashboard.dashboard"))

    return render_template("admin_login.html")


@admin_auth_bp.route("/request-2fa")
def request_admin_2fa():
    """
    Redirect dinspre dashboard normal → pagina de introducere cod 2FA.
    Se apelează când userul logat normal (is_admin=True) apasă 'Admin Dashboard'.
    Setează variabilele de sesiune pentru 2FA și redirecționează la /login?step=2fa.
    """
    if not session.get("user"):
        return redirect("/login")
    if not session.get("is_admin"):
        return redirect("/login")

    # Curăță orice sesiune admin existentă pentru a forța re-autentificarea
    for key in ["is_super_admin", "admin_user", "admin_username", "admin_name",
                "admin_id", "admin_login_time", "admin_session_expires_at",
                "admin_last_activity", "admin_extension_count",
                "admin_connection_active", "admin_connection_info"]:
        session.pop(key, None)

    # Populează sesiunea pentru pasul 2FA din datele sesiunii curente
    session["admin_2fa_email"] = session.get("user")
    session["admin_2fa_id"]   = session.get("IdConsultant")
    session["admin_2fa_name"] = session.get("NumeConsultant")
    session.modified = True

    logging.getLogger("admin_auth").info(
        f"🔐 Redirect 2FA solicitat de {session.get('user')} din dashboard normal"
    )
    return redirect("/login?step=2fa")


@admin_auth_bp.route("/api/login", methods=["POST"])
@admin_limiter.limit("3 per minute")
def api_admin_login():
    """API special pentru login admin - cu conexiune dedicată"""
    ip = request.remote_addr

    try:
        data = request.get_json() or {}
        password = data.get("password", "")
        IdConsultant = data.get("IdConsultant", "")

        if not password or IdConsultant is None or IdConsultant == "":
            return (
                jsonify({"success": False, "message": "Completați toate câmpurile!"}),
                400,
            )

        # Validare IdConsultant să fie numeric
        try:
            IdConsultant_int = int(IdConsultant)

        except ValueError:
            return (
                jsonify({"success": False, "message": "ID Consultant invalid!"}),
                400,
            )

        # Generează username-ul: C + lpad(IdConsultant, 3, "0")
        username = f"C{IdConsultant_int:03d}"

        # Verifică dacă admin-ul este blocat
        if is_admin_blocked(username):
            block_info = get_admin_block_info(username)
            logging.getLogger("admin_auth").warning(
                f"🚨 Admin blocat: {username} din IP: {ip}"
            )
            return (
                jsonify(
                    {
                        "success": False,
                        "message": f"Contul admin este blocat încă {block_info['remaining_minutes']} minute.",
                    }
                ),
                403,
            )

        # Verifică încercările eșuate
        failed_attempts = get_failed_admin_attempts(username, cast(str, ip))
        logging.getLogger("admin_auth").info(
            f"🔍 Admin {username} are {failed_attempts} încercări eșuate"
        )

        if failed_attempts >= 2:
            block_admin_account(username, duration=7200)
            logging.getLogger("admin_auth").error(
                f"🚨 Admin blocat după {failed_attempts} încercări: {username}"
            )
            return (
                jsonify(
                    {
                        "success": False,
                        "message": "CONT ADMIN BLOCAT! Prea multe încercări eșuate. Blocare: 2 ore.",
                    }
                ),
                403,
            )

        # Întârziere progresivă
        if failed_attempts > 0:
            delay = min(failed_attempts * 3, 15)
            logging.getLogger("admin_auth").info(f"⏱️ Întârziere admin: {delay}s")
            time.sleep(delay)

        # TESTEAZĂ CONEXIUNEA DIRECTĂ LA MYSQL
        admin_connection = create_admin_connection(username, password)

        if not admin_connection:
            increment_failed_admin_attempts(username, cast(str, ip))
            logging.getLogger("admin_auth").warning(
                f"❌ Conexiune MySQL eșuată pentru {username}, IP: {ip}"
            )
            return (
                jsonify({"success": False, "message": "Credențiale admin incorecte!"}),
                401,
            )

        # Verifică în baza de date dacă este admin (IdConsultant = 0)
        try:
            cursor = admin_connection.cursor()
            query = """
            SELECT cMail, IdConsultant, NumeConsultant
            FROM SVN_00.Consultanti
            WHERE IdConsultant = %s AND IdNivel >= 40 AND Ascuns=0 AND Plecat=0
            """
            cursor.execute(query, (IdConsultant_int,))
            result = cursor.fetchone()
            cursor.close()

            if not result:
                admin_connection.close()
                increment_failed_admin_attempts(username, cast(str, ip))
                logging.getLogger("admin_auth").warning(
                    f"❌ ID Consultant invalid: {IdConsultant}, IP: {ip}"
                )
                return (
                    jsonify({"success": False, "message": "ID Consultant nu există!"}),
                    401,
                )

            db_email, db_IdConsultant, db_name = result

        except Exception as db_error:
            admin_connection.close()
            increment_failed_admin_attempts(username, cast(str, ip))
            logging.getLogger("admin_auth").error(f"💥 Eroare DB admin: {db_error}")
            return (
                jsonify(
                    {
                        "success": False,
                        "message": "Eroare la verificarea permisiunilor!",
                    }
                ),
                500,
            )

        # SUCCESS - Resetează contoarele și setează sesiune
        clear_admin_attempts(username, cast(str, ip))

        # Stochează informații în sesiune
        current_time = time.time()
        timeout_minutes = int(os.getenv("SESSION_TIMEOUT", "15"))
        session["admin_user"]               = db_email
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

        # Stochează conexiunea (pentru moment o închidem, dar ai logica)
        store_admin_connection(admin_connection)
        admin_connection.close()  # Temporar - în realitate ai păstra-o

        return jsonify(
            {
                "success": True,
                "message": f"Bun venit, admin {db_name}!",
                "redirect": "/admin/dashboard",
            }
        )

    except Exception as e:
        logging.getLogger("admin_auth").error(f"💥 Eroare admin login: {e}")
        return (
            jsonify(
                {"success": False, "message": "Eroare tehnică la autentificare admin."}
            ),
            500,
        )


def create_admin_connection(username, password):
    """
    Creează conexiune MySQL dedicată pentru admin
    Această conexiune va fi folosită pe toată durata sesiunii admin
    """
    try:
        # Configurație conexiune admin
        config = {
            "host": os.getenv("DB_HOST", "localhost"),
            "port": int(os.getenv("DB_PORT", 3306)),
            "user": username,
            "password": password,
            "database": os.getenv("DB_NAME", "SVN_00"),
            "charset": "utf8mb4",
            "collation": "utf8mb4_unicode_ci",
            "autocommit": True,
            "raise_on_warnings": True,
            "connection_timeout": 10,
            "auth_plugin": "mysql_native_password",
        }

        connection = mysql.connector.connect(**config)

        if connection.is_connected():
            # Test conexiune cu un query simplu
            cursor = connection.cursor()
            cursor.execute("SELECT 1")
            cursor.fetchone()
            cursor.close()

            return connection
        else:
            logging.getLogger("admin_auth").error(
                f"❌ Conexiune admin eșuată: {username}"
            )
            return None

    except MySQLError as e:
        logging.getLogger("admin_auth").error(f"💥 Eroare MySQL admin {username}: {e}")
        return None

    except Exception as e:
        logging.getLogger("admin_auth").error(
            f"💥 Eroare generală admin {username}: {e}"
        )
        return None


def store_admin_connection(connection):
    """
    Stochează conexiunea admin în sesiune
    """
    # Nu poți stoca direct conexiunea MySQL în sesiune Flask
    # Dar poți stoca parametrii pentru a o recrea
    if connection and connection.is_connected():
        connection_info = connection.get_server_info()
        session["admin_connection_active"] = True
        session["admin_connection_info"] = connection_info
        logging.getLogger("admin_auth").info(
            f"📦 Conexiune admin stocată: {connection_info}"
        )
        return True
    return False


def get_admin_connection():
    """
    Obține conexiunea admin pentru sesiunea curentă
    Recreează conexiunea dacă este necesar
    """
    if not session.get("admin_connection_active") or not session.get("admin_username"):
        return None

    try:
        # Recreează conexiunea cu parametrii din sesiune
        username = session["admin_username"]
        # Parola nu o poți stoca în sesiune din motive de securitate
        # Trebuie să o ceri din nou sau să folosești un token

        logging.getLogger("admin_auth").info(f"🔄 Recreez conexiune admin: {username}")

        # Pentru moment, returnează None - va trebui să gestionezi altfel
        # Sau să stochezi conexiunea într-un cache global cu timeout
        return None

    except Exception as e:
        logging.getLogger("admin_auth").error(
            f"💥 Eroare recreare conexiune admin: {e}"
        )
        return None


def close_admin_connection():
    """
    Închide conexiunea admin la logout
    """
    if session.get("admin_connection_active"):
        session.pop("admin_connection_active", None)
        session.pop("admin_connection_info", None)
        logging.getLogger("admin_auth").info("🔒 Conexiune admin închisă")


@admin_auth_bp.route("/api/check-email", methods=["POST"])
@admin_limiter.limit("2 per minute")  # Limitează cererile de verificare email
def api_check_email():
    """Verifică email pentru admin și returnează informații despre cont"""
    ip = cast(str, request.remote_addr)
    logging.getLogger("auth").info(f"📥 API check-email solicitat de IP: {ip}")  # Logare IP pentru debugging
    try:
        data = request.get_json()
        logging.getLogger("auth").info(f"🔍 Verific email din IP: {ip} cu data {data}")

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
        SELECT IdConsultant, NumeConsultant
        FROM SVN_00.Consultanti
        WHERE cMail = %s AND IdNivel >= 40 AND Ascuns=0 AND Plecat=0
        """
        cursor.execute(query, (email,))
        result = cursor.fetchone()

        cursor.close()
        admin_conn.close()

        if result:
            IdConsultant, NumeConsultant = result

            logging.getLogger("auth").info(f"✅ Email găsit: {email}")

            return jsonify(
                {
                    "exists": True,
                    "NumeConsultant": NumeConsultant,
                    "IdConsultant": IdConsultant,
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
                    "message": "Email-ul nu este înregistrat în sistem",
                }
            )

    except Exception as e:
        logging.getLogger("auth").error(f"💥 Eroare check email: {e}")
        return (
            jsonify(
                {"exists": False, "message": "Eroare tehnică la verificarea email-ului (ADMIN)"}
            ),
            500,
        )


@admin_auth_bp.route("/api/verify-key", methods=["POST"])
@admin_limiter.limit("2 per minute")  # Limitează cererile de verificare cheie
def api_verify_key():
    """Verifică cheia specială pentru admin"""
    # DEBUG: Forțează reîncărcarea pentru testing
    logging.getLogger("admin_auth").info(f"Debug: {current_app.debug}")

    if current_app.debug:
        expected_key = reload_env_config()
    else:
        expected_key = os.getenv("ADMIN_MASTER_KEY", "")

    logging.getLogger("admin_auth").info(f"🔑 Cheie așteptată: {expected_key}")
    logging.getLogger("admin_auth").info(
        f"📁 Fișier .env găsit: {os.path.exists('.env')}"
    )

    try:
        data = request.get_json()
        admin_key = data.get("admin_key", "").strip()

        if not admin_key:
            return jsonify({"valid": False, "message": "Cheia lipsă"}), 400

        if admin_key == expected_key:
            return jsonify({"valid": True, "message": "Cheia este validă"})
        else:
            return jsonify({"valid": False, "message": "Cheia este invalidă"}), 401

    except Exception as e:
        logging.getLogger("admin_auth").error(f"💥 Eroare verificare cheie: {e}")
        return (
            jsonify({"valid": False, "message": "Eroare tehnică la verificarea cheii"}),
            500,
        )


def reload_env_config():
    """Forțează reîncărcarea configurației .env pentru debugging"""
    from dotenv import load_dotenv
    import os

    # Șterge variabila din cache
    if "ADMIN_MASTER_KEY" in os.environ:
        del os.environ["ADMIN_MASTER_KEY"]

    # Reîncarcă .env
    load_dotenv(override=True)  # override=True forțează actualizarea

    key = os.getenv("ADMIN_MASTER_KEY", "NOT_FOUND")
    logging.getLogger("admin_auth").info(f"🔄 ENV reîncărcat - ADMIN_MASTER_KEY: {key}")
    return key


@admin_auth_bp.route("/api/session-info", methods=["GET"])
def api_admin_session_info():
    """Returnează informații despre sesiunea admin (folosit de monitorizarea sesiunii)"""
    if not session.get("is_super_admin"):
        return jsonify({"success": False, "authenticated": False}), 401

    timeout_minutes = int(os.getenv("SESSION_TIMEOUT", "15"))
    current_time = time.time()
    expires_at = session.get("admin_session_expires_at", current_time + timeout_minutes * 60)
    remaining_seconds = max(0, expires_at - current_time)

    return jsonify({
        "success": True,
        "authenticated": True,
        "admin_user": session.get("admin_user"),
        "admin_name": session.get("admin_name"),
        "session_data": {
            "timeout_minutes": timeout_minutes,
            "remaining_seconds": remaining_seconds,
            "extension_count": session.get("admin_extension_count", 0),
            "max_extensions": 2,
        },
    })


@admin_auth_bp.route("/api/extend-session", methods=["POST"])
def api_admin_extend_session():
    """Prelungește sesiunea admin (maxim 2 ori)"""
    if not session.get("is_super_admin"):
        return jsonify({"success": False, "message": "No active admin session"}), 401

    extension_count = session.get("admin_extension_count", 0)
    if extension_count >= 2:
        return jsonify({
            "success": False,
            "message": "Numărul maxim de prelungiri (2) a fost atins.",
            "max_extensions_reached": True,
        }), 403

    timeout_minutes = int(os.getenv("SESSION_TIMEOUT", "15"))
    current_time = time.time()
    new_expires_at = current_time + (timeout_minutes * 60)

    session["admin_session_expires_at"] = new_expires_at
    session["admin_last_activity"]      = current_time
    session["admin_extension_count"]    = extension_count + 1
    session.modified = True

    logging.getLogger("admin_auth").info(
        f"🔄 Sesiune admin prelungită ({extension_count + 1}/2) pentru {session.get('admin_user')}"
    )

    return jsonify({
        "success": True,
        "extension_count": extension_count + 1,
        "max_extensions": 2,
        "new_expires_in": timeout_minutes * 60,
    })


@admin_auth_bp.route("/logout")
def admin_logout():
    """Logout admin"""
    admin_user = session.get("admin_user", "necunoscut")

    # Șterge toate datele admin din sesiune
    session.pop("admin_user", None)
    session.pop("admin_name", None)
    session.pop("is_super_admin", None)
    session.pop("admin_login_time", None)

    logging.getLogger("admin_auth").info(f"🚪 Admin logout: {admin_user}")

    return redirect(url_for("admin_auth.admin_login"))


@admin_auth_bp.route("/status")
def admin_status():
    """Status sesiune admin (pentru debugging)"""
    if not session.get("is_super_admin"):
        return jsonify({"authenticated": False}), 401

    login_time = session.get("admin_login_time", 0)
    session_age = time.time() - login_time if login_time else 0

    return jsonify(
        {
            "authenticated": True,
            "admin_user": session.get("admin_user"),
            "admin_name": session.get("admin_name"),
            "session_age_minutes": round(session_age / 60, 1),
            "login_time": (
                datetime.fromtimestamp(login_time).strftime("%Y-%m-%d %H:%M:%S")
                if login_time
                else None
            ),
        }
    )


def is_account_blocked(email: str) -> bool:
    key = f"blocked_account:{email}"
    return bool(redis_client.exists(key))


# Contor pentru încercări eșuate
def increment_failed_attempts(email: str, ip: str) -> int:
    key = f"failed_attempts:{email}:{ip}"
    logging.getLogger("admin_auth").debug(f"Creating Redis key: {key}")

    try:
        count = cast(int, redis_client.incr(key))
        logging.getLogger("admin_auth").debug(f"Redis incr result: {count}")
        if count == 1:
            redis_client.expire(key, 3600)
            logging.getLogger("admin_auth").debug(f"Set expiry for key: {key}")
        return count
    except Exception as e:
        logging.getLogger("admin_auth").error(f"Redis error: {e}")
        return 0


def get_failed_attempts(email: str, ip: str) -> int:
    key = f"failed_attempts:{email}:{ip}"
    count = cast(int, redis_client.get(key))
    logging.getLogger("auth").info(
        f"🔍 Verificări eșuate pentru {email} din IP: {ip} - {count} încercări"
    )
    return int(count) if count else 0


def block_account(email: str, duration: int = 3600):
    key = f"blocked_account:{email}"
    redis_client.setex(key, duration, "blocked")
    logging.getLogger("auth").info(
        f"🚨 Cont blocat temporar: {email} pentru 3600 secunde"
    )


# ========== MIDDLEWARE PENTRU VERIFICARE ADMIN ==========
def require_admin():
    """Decorator pentru a verifica dacă utilizatorul este admin și sesiunea nu a expirat"""

    def decorator(f):
        def wrapper(*args, **kwargs):
            if not session.get("is_super_admin"):
                # Dacă este logat normal cu drepturi admin → redirect la 2FA
                if session.get("user") and session.get("is_admin"):
                    return redirect(url_for("admin_auth.request_admin_2fa"))
                # Altfel → redirect la pagina principală de login
                return redirect("/login")

            # Verifică expirarea sesiunii admin
            expires_at = session.get("admin_session_expires_at")
            if not expires_at or time.time() > expires_at:
                logging.getLogger("admin_auth").info(
                    f"⏰ Sesiune admin expirată pentru {session.get('admin_user')}"
                )
                # Curăță datele admin din sesiune
                for key in ["is_super_admin", "admin_user", "admin_username",
                            "admin_name", "admin_id", "admin_login_time",
                            "admin_session_expires_at", "admin_last_activity",
                            "admin_extension_count", "admin_connection_active"]:
                    session.pop(key, None)
                session.modified = True
                return redirect("/login?admin_expired=1")

            return f(*args, **kwargs)

        wrapper.__name__ = f.__name__
        return wrapper

    return decorator
