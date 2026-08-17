# ========== app.py (OPTIMIZAT CU LOG-URI CURATE) ==========
"""
🚀 FLASK APPLICATION - AD.CREDIT 3
Main application with modular dashboard system
✨ LOG-URI CURATE - fără IP și timestamp din Werkzeug
"""
import os
from dotenv import load_dotenv

# Încarcă environment variables
load_dotenv()

from flask import (
    Flask,
    redirect,
    render_template_string,
    url_for,
    request,
    session,
    jsonify,
    after_this_request,
)

import secrets
import logging
from datetime import timedelta, datetime
import time
import uuid
from datetime import datetime, timedelta


# ========== 🧹 SOLUȚIA PENTRU LOG-URI CURATE ==========
# Importă logging pentru configurarea log-urilor
def setup_clean_werkzeug_logging():
    """
    🎯 Configurează Werkzeug să afișeze log-uri curate
    Păstrează log-urile normale din toate celelalte module
    """

    # 1️⃣ Configurează ROOT logger-ul pentru toate modulele
    root_logger = logging.getLogger()

    # Șterge handler-ele existente de la root
    root_logger.handlers.clear()

    # Creează handler principal pentru toate modulele
    main_handler = logging.StreamHandler()
    main_formatter = logging.Formatter(
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )
    main_handler.setFormatter(main_formatter)
    root_logger.addHandler(main_handler)
    root_logger.setLevel(logging.INFO)

    # 2️⃣ Configurează special doar logger-ul Werkzeug
    werkzeug_logger = logging.getLogger("werkzeug")

    # Formatter special pentru Werkzeug (elimină IP-ul)
    class CleanWerkzeugFormatter(logging.Formatter):
        """
        Formatter care păstrează formatul complet cu timestamp pentru log-urile normale,
        dar elimină doar IP-ul din request-urile HTTP
        """

        def __init__(self):
            # Format complet cu timestamp pentru log-urile normale
            super().__init__("%(asctime)s - %(name)s - %(levelname)s - %(message)s")

        def format(self, record):
            message = record.getMessage()

            # Verifică dacă e un mesaj HTTP standard de la Werkzeug cu IP
            if " - - [" in message and '] "' in message:
                # Extrage doar partea cu request-ul (fără IP și timestamp din paranteză)
                start_quote = message.find('] "') + 2
                if start_quote > 1:
                    clean_request = message[start_quote:]
                    # Recreează record-ul cu mesajul curat
                    record.msg = clean_request
                    record.args = ()
                    # Aplică formatul complet cu timestamp
                    return super().format(record)

            # Pentru alte mesaje Werkzeug, aplică formatul complet normal
            return super().format(record)

    # Aplică formatter-ul special doar la Werkzeug
    werkzeug_logger.handlers.clear()
    werkzeug_handler = logging.StreamHandler()
    werkzeug_handler.setFormatter(CleanWerkzeugFormatter())
    werkzeug_logger.addHandler(werkzeug_handler)
    werkzeug_logger.setLevel(logging.INFO)

    # 🔴 IMPORTANT: Previne propagarea la root pentru a evita dublarea
    werkzeug_logger.propagate = False

    # 3️⃣ Toate celelalte module vor folosi root logger-ul automat

    return root_logger


def disable_werkzeug_ip_logging():
    """
    🚫 Alternativă: Disable complet logging-ul IP pentru Werkzeug
    Păstrează doar informațiile esențiale
    """
    import logging

    # Creează un filter care elimină IP-ul din mesaje
    class NoIPFilter(logging.Filter):
        def filter(self, record):
            if hasattr(record, "getMessage"):
                message = record.getMessage()
                # Înlocuiește pattern-ul cu IP cu versiunea curată
                import re

                # Pattern pentru log-uri Werkzeug: "IP - - [timestamp] request status size"
                clean_message = re.sub(
                    r"^\d+\.\d+\.\d+\.\d+ - - \[[^\]]+\] ", "", message
                )
                # Actualizează mesajul în record
                record.msg = clean_message
                record.args = ()
            return True

    # Aplică filtrul la Werkzeug
    werkzeug_logger = logging.getLogger("werkzeug")
    werkzeug_logger.addFilter(NoIPFilter())


# ========== INIȚIALIZARE ==========
# 🧹 CONFIGUREAZĂ LOG-URILE CURATE ÎNAINTE DE CREAREA APP-ULUI
setup_clean_werkzeug_logging()

# Creează aplicația Flask
app = Flask(__name__)
# Seteaza debug explicit din env (necesar cand ruleaza prin gunicorn)
app.debug = os.getenv("FLASK_DEBUG", "False").lower() == "true"
# ========== CONFIGURAȚII ==========

# 🔄 Cache busting configuration
CACHE_BUSTER = f"{int(time.time())}_{str(uuid.uuid4())[:8]}"


@app.context_processor
def inject_cache_buster():
    """💥 Injectează cache buster în toate template-urile"""
    return {
        "cache_buster": CACHE_BUSTER,
        "app_version": "3.0.0",
        "company_name": "SVN ROMANIA",
        "current_user": session.get("user"),
        "current_department": session.get("department"),
        "is_authenticated": "user" in session,
        "debug_mode": app.debug,
        "server_restart_time": int(time.time()),
    }


@app.before_request
def force_cache_invalidation():
    """🧹 Forțează invalidarea cache-ului pentru resurse critice"""
    if request.path.startswith("/api/"):

        @after_this_request
        def add_no_cache_headers(response):
            response.headers["Cache-Control"] = (
                "no-cache, no-store, must-revalidate, private"
            )
            response.headers["Pragma"] = "no-cache"
            response.headers["Expires"] = "0"
            response.headers["Last-Modified"] = datetime.now().strftime(
                "%a, %d %b %Y %H:%M:%S GMT"
            )
            response.headers["ETag"] = f'"{CACHE_BUSTER}"'
            return response


# ========== SESSION INVALIDATION ==========


def invalidate_all_sessions_on_restart():
    """🔥 Invalidează toate sesiunile existente la restart"""
    new_secret = secrets.token_hex(32)
    app.secret_key = new_secret
    key = os.getenv("ADMIN_MASTER_KEY", "NOT_FOUND")
    app.logger.info(f"🔥 TOATE SESIUNILE AU FOST INVALIDATE!")


# ========== CONFIGURĂRI APLICAȚIE ==========

# Security
app.secret_key = os.getenv("FLASK_SECRET_KEY", secrets.token_hex(32))

# Session configuration
app.config["SESSION_COOKIE_SECURE"] = (
    os.getenv("HTTPS_ENABLED", "False").lower() == "true"
)
app.config["SESSION_COOKIE_HTTPONLY"] = True
app.config["SESSION_COOKIE_SAMESITE"] = "Lax"
app.config["PERMANENT_SESSION_LIFETIME"] = timedelta(
    minutes=int(os.getenv("SESSION_TIMEOUT", "10"))
)

# Upload limits
app.config["MAX_CONTENT_LENGTH"] = 16 * 1024 * 1024

# JSON configuration
app.config["JSON_SORT_KEYS"] = False
app.config["JSONIFY_PRETTYPRINT_REGULAR"] = True


# ========== LOGGING CONFIGURATION ==========


def setup_application_logging():
    """🔧 Configurează logging-ul pentru aplicație (complementar cu root logger)"""
    log_level = os.getenv("LOG_LEVEL", "INFO").upper()

    # Logger-ul aplicației va folosi root logger-ul configurat în setup_clean_werkzeug_logging()
    app_logger = logging.getLogger("app")
    app_logger.setLevel(getattr(logging, log_level, logging.INFO))

    # Nu mai adăugăm handler separat - va folosi root logger-ul
    # app_logger.propagate = True (default) - pentru a folosi root handler-ul

    return app_logger


# Configurează logging-ul aplicației
app_logger = setup_application_logging()


# ========== BLUEPRINTS ==========
# Importă și înregistrează blueprints
try:
    from routes.auth import auth_bp
    from routes.admin_auth import admin_auth_bp
    from routes.admin_dashboard import admin_dashboard_bp
    from routes.dashboard import dashboard_bp
    from routes.settings import settings_bp

    app.register_blueprint(auth_bp)
    app.register_blueprint(dashboard_bp)
    app.register_blueprint(admin_auth_bp, url_prefix="/admin")
    app.register_blueprint(admin_dashboard_bp, url_prefix="/admin")
    app.register_blueprint(settings_bp)

except ImportError as e:
    app_logger.error(f"❌ Eroare la încărcarea blueprints: {e}")


# ========== MIDDLEWARE ==========


@app.after_request
def after_request(response):
    """Middleware pentru header-e de securitate"""
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"

    if request.path.startswith("/api/"):
        response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
        response.headers["Pragma"] = "no-cache"
        response.headers["Expires"] = "0"
    return response


# ========== ROUTES PRINCIPALE ==========


@app.route("/")
def index():
    """Redirecționează către dashboard sau login"""
    return redirect(url_for("auth.login"))


@app.route("/logout")
def logout():
    """Logout complet cu ștergere sesiune"""
    session.clear()
    session.permanent = False
    return redirect(url_for("auth.login"))


@app.route("/health")
def health_check():
    """Health check pentru monitoring"""
    try:
        from modules.db import get_service_conn

        conn = get_service_conn()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        cursor.fetchone()
        cursor.close()
        conn.close()

        db_status = "healthy"
    except Exception as e:
        db_status = f"error: {str(e)}"

    health_data = {
        "status": "healthy" if db_status == "healthy" else "degraded",
        "timestamp": datetime.now().isoformat(),
        "database": db_status,
        "version": "3.0.0",
    }

    status_code = 200 if health_data["status"] == "healthy" else 503
    return jsonify(health_data), status_code


@app.route("/version")
def version_info():
    """Informații despre versiunea aplicației"""
    return jsonify(
        {
            "app_version": "3.0.0",
            "flask_version": "Latest",
            "python_version": "3.x",
            "build_date": "2024-12-XX",
            "logging_mode": "clean_werkzeug",
        }
    )


# ========== ERROR HANDLERS ==========


@app.errorhandler(404)
def handle_404(error):
    """Handler pentru pagini inexistente"""
    if request.path.startswith("/api/"):
        return (
            jsonify(
                {
                    "error": "Endpoint not found",
                    "path": request.path,
                }
            ),
            404,
        )

    return (
        render_template_string(
            """
        <div style="padding:20px;font-family:Arial,sans-serif;max-width:600px;margin:50px auto;">
            <h2 style="color:#dc2626;">🚫 Pagina nu a fost găsită</h2>
            <p>Calea <code>{{ path }}</code> nu există.</p>
            <a href="{{ url_for('index') }}" style="background:#2563eb;color:white;padding:8px 16px;text-decoration:none;border-radius:4px;">
                🏠 Acasă
            </a>
        </div>
    """,
            path=request.path,
        ),
        404,
    )


@app.errorhandler(500)
def handle_500(error):
    """Handler pentru erori interne"""
    error_id = secrets.token_hex(8)
    app_logger.error(f"Internal error {error_id}: {str(error)}")

    if request.path.startswith("/api/"):
        return (
            jsonify(
                {
                    "error": "Internal server error",
                    "error_id": error_id,
                }
            ),
            500,
        )

    return (
        render_template_string(
            """
        <div style="padding:20px;font-family:Arial,sans-serif;max-width:600px;margin:50px auto;">
            <h2 style="color:#dc2626;">⚠️ Eroare internă</h2>
            <p><strong>Error ID:</strong> <code>{{ error_id }}</code></p>
            <a href="{{ url_for('index') }}">🏠 Înapoi</a>
        </div>
    """,
            error_id=error_id,
        ),
        500,
    )


@app.errorhandler(401)
def handle_401(error):
    """Handler pentru erori de autentificare"""
    if request.path.startswith("/api/"):
        return (
            jsonify(
                {
                    "error": "Authentication required",
                    "redirect": "/login",
                }
            ),
            401,
        )

    return redirect(url_for("auth.login"))


# ========== DEVELOPMENT HELPERS ==========
@app.route("/debug/logs")
def debug_logs():
    """Test pentru verificarea log-urilor curate"""
    if not app.debug:
        return "Debug mode disabled", 403

    app_logger.info("🧪 Test mesaj din aplicație")
    werkzeug_logger = logging.getLogger("werkzeug")
    werkzeug_logger.info("🧪 Test mesaj din Werkzeug")

    return jsonify(
        {
            "message": "Log test executat - verifică consola",
            "log_format": "clean_werkzeug_enabled",
            "timestamp": datetime.now().isoformat(),
        }
    )


# ========== ENVIRONMENT VALIDATION ==========
def validate_environment():
    """Validează variabilele de environment necesare"""
    required_vars = ["DB_HOST", "DB_SERVICE_USER", "DB_SERVICE_PASSWORD", "DB_NAME"]
    missing_vars = [var for var in required_vars if not os.getenv(var)]

    if missing_vars:
        app_logger.error(f"❌ Missing environment variables: {', '.join(missing_vars)}")
        return False

    app_logger.info("✅ Environment validation passed")
    return True


# ========== MAIN EXECUTION ==========
if __name__ == "__main__":
    # Evită dubla execuție în debug mode
    if not os.environ.get("WERKZEUG_RUN_MAIN"):
        # Clear terminal la primera pornire
        # os.system("cls" if os.name == "nt" else "clear")

        app_logger.info("=" * 60)
        app_logger.info(
            f"🚀 PORNIRE AD.CREDIT 3 - {datetime.now().strftime('%H:%M:%S')}"
        )
        app_logger.info("=" * 60)

        # Invalidează sesiunile
        invalidate_all_sessions_on_restart()

        app_logger.info(f"💥 Cache Buster: {CACHE_BUSTER}")

        # Validare environment
        if not validate_environment():
            app_logger.warning("⚠️ Lipsesc variabilele de environment!")

        app_logger.info("🌐 Aplicația va fi disponibilă la: http://localhost:5001")
        app_logger.info("🔧 Debug mode: ON")
        app_logger.info("=" * 60)

    # Pornește aplicația cu log-uri curate
    app.run(
        host=os.getenv("FLASK_HOST", "0.0.0.0"),
        port=int(os.getenv("FLASK_PORT", "5001")),
        debug=os.getenv("FLASK_DEBUG", "True").lower() == "true",
        use_reloader=False,
        threaded=True,
    )
