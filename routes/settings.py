# ========== routes/settings.py - Completare ==========
from flask import (
    Blueprint,
    render_template,
    request,
    session,
    jsonify,
    redirect,
    url_for,
)

from services.column_settings import (
    load_column_settings,
    save_column_settings,
    reset_column_settings,
    load_available_columns,
)

from modules.db import get_service_conn
import logging

logger = logging.getLogger(__name__)
settings_bp = Blueprint("settings", __name__)


@settings_bp.route("/column-settings")
def column_settings():
    """Pagina de gestionare a coloanelor"""
    if "user" not in session or "department" not in session:
        return redirect(url_for("auth.login"))
    return render_template("column_settings.html")


@settings_bp.route("/api/available_columns", methods=["POST"])
def get_available_columns():
    """
    Returnează toate coloanele implicite pentru un anumit tab.
    """
    try:
        if "user" not in session or "department" not in session:
            return jsonify({"success": False, "message": "Sesiune expirată."}), 401

        data = request.get_json()
        sel_tab = data.get("selTab", "nvB1")
        department = session["department"]

        conn = get_service_conn()
        try:
            result = load_available_columns(conn, department, sel_tab)
            return jsonify(result)
        finally:
            conn.close()

    except Exception as e:
        logger.error(f"Eroare la obținerea coloanelor disponibile: {e}")
        import traceback

        traceback.print_exc()
        return jsonify({"success": False, "message": str(e)}), 500


@settings_bp.route("/api/column-settings", methods=["GET"])
def api_column_settings():
    conn = None

    if "user" not in session or "department" not in session:
        return jsonify({"success": False, "message": "Sesiune expirată."}), 401

    try:
        conn = get_service_conn()
        result = load_column_settings(
            conn,
            session["department"],
            session["user"],
            request.args.get("tab", "nvB1"),
        )
        return jsonify(result)

    except ValueError as ve:
        return jsonify({"success": False, "message": str(ve)}), 404
    except Exception as ex:
        return jsonify({"success": False, "message": str(ex)}), 500
    finally:
        if conn:
            conn.close()


@settings_bp.route("/api/manage_column_settings", methods=["POST"])
def manage_column_settings():
    if "user" not in session or "department" not in session:
        return jsonify({"success": False, "message": "Sesiune expirată."}), 401

    data = request.get_json()
    action = data.get("action", "get")
    sel_tab = data.get("selTab", "nvB1")
    email = session["user"]
    department = session["department"]

    conn = get_service_conn()
    try:
        if action == "get":
            return jsonify(load_column_settings(conn, department, email, sel_tab))
        elif action == "update":
            columns = data.get("columns", [])
            if not columns:
                return (
                    jsonify(
                        {"success": False, "message": "Nu au fost trimise coloane."}
                    ),
                    400,
                )
            save_column_settings(conn, department, email, sel_tab, columns)
            return jsonify(
                {
                    "success": True,
                    "message": f"Setări salvate pentru {len(columns)} coloane.",
                    "updated_count": len(columns),
                }
            )
        elif action == "reset":
            reset_column_settings(conn, department, email, sel_tab)
            return jsonify(
                {
                    "success": True,
                    "message": "Setările au fost resetate la valorile implicite.",
                }
            )
        else:
            return jsonify({"success": False, "message": "Acțiune necunoscută."}), 400
    except ValueError as ve:
        return jsonify({"success": False, "message": str(ve)}), 404
    except Exception as ex:
        return jsonify({"success": False, "message": str(ex)}), 500
    finally:
        conn.close()
