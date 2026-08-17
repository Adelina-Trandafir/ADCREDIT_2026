# ========== routes/admin_dashboard.py ==========
"""
🎛️ ADMIN DASHBOARD MODULE
Dashboard și funcționalități pentru administratori
"""

from flask import (
    Blueprint,
    render_template,
    request,
    session,
    redirect,
    url_for,
    jsonify,
)
from datetime import datetime, timedelta
from typing import cast
import os
import time
import logging
import redis
from typing import cast, List
from .admin_auth import require_admin, redis_client

# Creează blueprint dashboard admin
admin_dashboard_bp = Blueprint("admin_dashboard", __name__, url_prefix="/admin")
logger = logging.getLogger("admin_dashboard")


# ========== ROUTE HANDLERS ==========


@admin_dashboard_bp.route("/dashboard")
@require_admin()
def dashboard():
    """Dashboard principal admin"""
    return render_template("admin_dashboard.html")


@admin_dashboard_bp.route("/unlock")
@require_admin()
def unlock_page():
    """Pagina de deblocare conturi"""
    return render_template("admin_unlock.html")


# ========== API ENDPOINTS ==========


@admin_dashboard_bp.route("/api/stats", methods=["GET"])
@require_admin()
def api_get_stats():
    """Returnează statistici generale sistem"""
    try:
        # Statistici Redis
        redis_stats = get_redis_stats()

        # Statistici utilizatori
        user_stats = get_user_stats()

        # Statistici admin
        admin_stats = get_admin_stats()

        return jsonify(
            {
                "success": True,
                "stats": {
                    "redis": redis_stats,
                    "users": user_stats,
                    "admin": admin_stats,
                    "timestamp": datetime.now().isoformat(),
                },
            }
        )

    except Exception as e:
        logging.getLogger("admin_dashboard").error(
            f"Eroare la obținerea statisticilor: {e}"
        )
        return jsonify({"success": False, "error": str(e)}), 500


from typing import cast, List
from redis import Redis
from flask import jsonify, request, session
import logging


@admin_dashboard_bp.route("/api/blocked-accounts", methods=["GET"])
@require_admin()
def api_get_blocked_accounts():
    """Returnează toate conturile blocate"""
    try:
        # Cast keys to List[str]
        user_blocked = cast(List[str], redis_client.keys("blocked_account:*"))
        user_attempts = cast(List[str], redis_client.keys("failed_attempts:*"))
        admin_blocked = cast(List[str], redis_client.keys("blocked_admin:*"))
        admin_attempts = cast(List[str], redis_client.keys("failed_admin_attempts:*"))

        blocked_accounts = []

        # Procesează conturile utilizatori blocate
        for key in user_blocked:
            email = key.replace("blocked_account:", "")
            ttl = cast(int, redis_client.ttl(key))  # Cast ttl to int
            blocked_accounts.append(
                {
                    "email": email,
                    "type": "user",
                    "remaining_seconds": ttl,
                    "remaining_minutes": round(ttl / 60, 1) if ttl > 0 else 0,
                    "status": "blocked",
                }
            )

        # Procesează conturile admin blocate
        for key in admin_blocked:
            email = key.replace("blocked_admin:", "")
            ttl = cast(int, redis_client.ttl(key))  # Cast ttl to int
            blocked_accounts.append(
                {
                    "email": email,
                    "type": "admin",
                    "remaining_seconds": ttl,
                    "remaining_minutes": round(ttl / 60, 1) if ttl > 0 else 0,
                    "status": "blocked",
                }
            )

        # Adaugă și conturile cu încercări eșuate (nu blocate încă)
        for key in user_attempts:
            email_ip = key.replace("failed_attempts:", "")
            email = (
                email_ip.split(":")[0] if ":" in email_ip else email_ip
            )  # Fixed syntax
            attempts = cast(str, redis_client.get(key))  # Cast get to str
            ttl = cast(int, redis_client.ttl(key))  # Cast ttl to int
            if not any(
                acc["email"] == email and acc["type"] == "user"
                for acc in blocked_accounts
            ):
                blocked_accounts.append(
                    {
                        "email": email,
                        "type": "user",
                        "attempts": int(attempts) if attempts else 0,
                        "remaining_seconds": ttl,
                        "remaining_minutes": round(ttl / 60, 1) if ttl > 0 else 0,
                        "status": "warning",
                    }
                )

        return jsonify(
            {
                "success": True,
                "blocked_accounts": blocked_accounts,
                "total_blocked": len(
                    [acc for acc in blocked_accounts if acc["status"] == "blocked"]
                ),
                "total_warnings": len(
                    [acc for acc in blocked_accounts if acc["status"] == "warning"]
                ),
            }
        )

    except Exception as e:
        logging.getLogger("admin_dashboard").error(
            f"Eroare la obținerea conturilor blocate: {e}"
        )
        return jsonify({"success": False, "error": str(e)}), 500


@admin_dashboard_bp.route("/api/unlock-account", methods=["POST"])
@require_admin()
def api_unlock_account():
    """Deblochează un cont specific"""
    try:
        data = request.get_json()
        email = data.get("email", "").strip()
        account_type = data.get("type", "user")  # user sau admin

        if not email:
            return (
                jsonify({"success": False, "message": "Email-ul este obligatoriu!"}),
                400,
            )

        unlocked_keys = []

        if account_type == "user":
            # Șterge blocarea utilizator
            user_block_key = f"blocked_account:{email}"
            if cast(int, redis_client.exists(user_block_key)):  # Cast to int
                redis_client.delete(user_block_key)
                unlocked_keys.append(user_block_key)

            # Șterge și încercările eșuate pentru toate IP-urile
            attempt_keys = cast(
                List[str], redis_client.keys(f"failed_attempts:{email}:*")
            )  # Cast to List[str]
            for key in attempt_keys:
                redis_client.delete(key)
                unlocked_keys.append(key)

        elif account_type == "admin":
            # Șterge blocarea admin
            admin_block_key = f"blocked_admin:{email}"
            if cast(int, redis_client.exists(admin_block_key)):  # Cast to int
                redis_client.delete(admin_block_key)
                unlocked_keys.append(admin_block_key)

            # Șterge și încercările eșuate admin pentru toate IP-urile
            admin_attempt_keys = cast(
                List[str], redis_client.keys(f"failed_admin_attempts:{email}:*")
            )  # Cast to List[str]
            for key in admin_attempt_keys:
                redis_client.delete(key)
                unlocked_keys.append(key)

        admin_user = session.get("admin_user", "necunoscut")
        logging.getLogger("admin_dashboard").info(
            f"🔓 UNLOCK: {admin_user} a deblocat contul {account_type} {email}"
        )

        return jsonify(
            {
                "success": True,
                "message": f"Contul {account_type} {email} a fost deblocat cu succes!",
                "unlocked_keys": len(unlocked_keys),
                "keys_removed": unlocked_keys,
            }
        )

    except Exception as e:
        logging.getLogger("admin_dashboard").error(
            f"Eroare la deblocarea contului: {e}"
        )
        return jsonify({"success": False, "error": str(e)}), 500


@admin_dashboard_bp.route("/api/unlock-all", methods=["POST"])
@require_admin()
def api_unlock_all():
    """Deblochează toate conturile blocate"""
    try:
        data = request.get_json()
        account_type = data.get("type", "all")  # user, admin, sau all

        unlocked_keys = []

        if account_type in ["user", "all"]:
            # Șterge toate blocările utilizatori
            user_blocks = cast(
                List[str], redis_client.keys("blocked_account:*")
            )  # Cast to List[str]
            user_attempts = cast(
                List[str], redis_client.keys("failed_attempts:*")
            )  # Cast to List[str]
            for key in user_blocks + user_attempts:  # Now valid
                redis_client.delete(key)
                unlocked_keys.append(key)

        if account_type in ["admin", "all"]:
            # Șterge toate blocările admin
            admin_blocks = cast(
                List[str], redis_client.keys("blocked_admin:*")
            )  # Cast to List[str]
            admin_attempts = cast(
                List[str], redis_client.keys("failed_admin_attempts:*")
            )  # Cast to List[str]
            for key in admin_blocks + admin_attempts:  # Now valid
                redis_client.delete(key)
                unlocked_keys.append(key)

        admin_user = session.get("admin_user", "necunoscut")
        logging.getLogger("admin_dashboard").warning(
            f"🔓🔓 UNLOCK ALL: {admin_user} a deblocat TOATE conturile {account_type} ({len(unlocked_keys)} chei)"
        )

        return jsonify(
            {
                "success": True,
                "message": f"Toate conturile {account_type} au fost deblocate!",
                "unlocked_keys": len(unlocked_keys),
                "keys_removed": unlocked_keys,
            }
        )

    except Exception as e:
        logging.getLogger("admin_dashboard").error(f"Eroare la deblocarea totală: {e}")
        return jsonify({"success": False, "error": str(e)}), 500


@admin_dashboard_bp.route("/api/system-info", methods=["GET"])
@require_admin()
def api_get_system_info():
    """Returnează informații sistem pentru monitoring"""
    try:
        # Informații Redis
        redis_info = cast(dict, redis_client.info())  # Cast to dict

        # Statistici aplicație
        app_stats = {
            "admin_session": {
                "user": session.get("admin_user"),
                "login_time": session.get("admin_login_time"),
                "session_age_minutes": round(
                    (time.time() - session.get("admin_login_time", 0)) / 60, 1
                ),
            },
            "redis_connection": {
                "connected": True,
                "version": redis_info.get("redis_version"),
                "memory_used": redis_info.get("used_memory_human"),
                "total_keys": (
                    redis_info.get("db0", {}).get("keys", 0)
                    if "db0" in redis_info
                    else 0
                ),
            },
        }

        return jsonify(
            {
                "success": True,
                "system_info": app_stats,
                "timestamp": datetime.now().isoformat(),
            }
        )

    except Exception as e:
        logging.getLogger("admin_dashboard").error(
            f"Eroare la obținerea info sistem: {e}"
        )
        return (
            jsonify(
                {
                    "success": False,
                    "error": str(e),
                    "system_info": {
                        "redis_connection": {"connected": False, "error": str(e)}
                    },
                }
            ),
            500,
        )


# ========== HELPER FUNCTIONS ==========
def get_redis_stats():
    """Obține statistici Redis"""
    try:
        info = cast(dict, redis_client.info())

        user_blocks = len(cast(List[str], redis_client.keys("blocked_account:*")))
        user_attempts = len(cast(List[str], redis_client.keys("failed_attempts:*")))
        admin_blocks = len(cast(List[str], redis_client.keys("blocked_admin:*")))
        admin_attempts = len(
            cast(List[str], redis_client.keys("failed_admin_attempts:*"))
        )

        return {
            "connected": True,
            "version": info.get("redis_version"),
            "memory_used": info.get("used_memory_human"),
            "total_keys": info.get("db0", {}).get("keys", 0) if "db0" in info else 0,
            "user_blocked_accounts": user_blocks,
            "user_failed_attempts": user_attempts,
            "admin_blocked_accounts": admin_blocks,
            "admin_failed_attempts": admin_attempts,
            "uptime_seconds": info.get("uptime_in_seconds", 0),
        }
    except Exception as e:
        return {"connected": False, "error": str(e)}


def get_user_stats():
    """Obține statistici utilizatori din DB"""
    try:
        from modules.db import get_service_conn

        conn = get_service_conn()
        cursor = conn.cursor()

        # Statistici generale utilizatori
        cursor.execute(
            "SELECT COUNT(*) FROM SVN_00.Consultanti WHERE Ascuns = 0 AND Plecat = 0"
        )
        total_users = cursor.fetchone()[0]

        cursor.execute(
            "SELECT COUNT(*) FROM SVN_00.Consultanti WHERE Ascuns = 1 OR Plecat = 1"
        )
        inactive_users = cursor.fetchone()[0]

        cursor.execute("SELECT COUNT(*) FROM SVN_00.Consultanti WHERE IdConsultant = 0")
        admin_users = cursor.fetchone()[0]

        cursor.close()
        conn.close()

        return {
            "total_active": total_users,
            "total_inactive": inactive_users,
            "total_admins": admin_users,
            "total_all": total_users + inactive_users,
        }

    except Exception as e:
        return {"error": str(e)}


def get_admin_stats():
    """Obține statistici admin curente"""
    return {
        "current_admin": session.get("admin_user"),
        "login_time": session.get("admin_login_time"),
        "session_duration_minutes": round(
            (time.time() - session.get("admin_login_time", 0)) / 60, 1
        ),
    }


# ========== STATISTICI BUSINESS ==========

ALLOWED_DBS = ["SVN_IM", "SVN_NP", "SVN_AS"]


@admin_dashboard_bp.route("/statistici")
@require_admin()
def statistici():
    """Pagina de statistici business"""
    return render_template("admin_stats.html")


@admin_dashboard_bp.route("/api/business-kpis", methods=["GET"])
@require_admin()
def api_business_kpis():
    db = request.args.get("db", "SVN_IM")
    if db not in ALLOWED_DBS:
        return jsonify({"success": False, "error": "DB invalid"}), 400
    conn = None
    try:
        from modules.db import get_service_conn
        conn = get_service_conn()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(f"""
            SELECT
              (SELECT COUNT(*) FROM {db}.Baza WHERE Ascuns=0) as total_leads,
              (SELECT COUNT(*) FROM {db}.Baza WHERE Ascuns=0 AND Nou=1) as leads_noi,
              (SELECT COUNT(*) FROM {db}.Baza WHERE Ascuns=0 AND DATE(DataPrimire) = CURDATE()) as leads_azi,
              (SELECT COUNT(*) FROM {db}.Baza WHERE Ascuns=0 AND DataPrimire >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)) as leads_30zile,
              (SELECT COUNT(*) FROM {db}.Dosar WHERE Ascuns=0) as total_dosare,
              (SELECT COUNT(*) FROM {db}.Dosar WHERE Ascuns=0 AND DataDebursare IS NOT NULL) as dosare_debursate,
              (SELECT COUNT(*) FROM {db}.Clienti WHERE Ascuns=0) as total_clienti,
              (SELECT COALESCE(SUM(ValoareCreditRON),0) FROM {db}.Dosar WHERE Ascuns=0) as valoare_totala_ron,
              (SELECT COALESCE(SUM(ValoareCreditRON),0) FROM {db}.Dosar WHERE Ascuns=0 AND DataDebursare IS NOT NULL) as valoare_debursata_ron,
              (SELECT COUNT(*) FROM {db}.Dosar WHERE Ascuns=0 AND DataRespingere IS NOT NULL) as dosare_respinse
        """)
        row = cursor.fetchone()
        if row:
            for k, v in row.items():
                from decimal import Decimal
                if isinstance(v, Decimal):
                    row[k] = float(v)
        cursor.close()
        return jsonify({"success": True, "data": row})
    except Exception as e:
        logger.error(f"Eroare business-kpis: {e}")
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if conn:
            conn.close()


@admin_dashboard_bp.route("/api/dosare-by-status", methods=["GET"])
@require_admin()
def api_dosare_by_status():
    db = request.args.get("db", "SVN_IM")
    if db not in ALLOWED_DBS:
        return jsonify({"success": False, "error": "DB invalid"}), 400
    conn = None
    try:
        from modules.db import get_service_conn
        from decimal import Decimal
        conn = get_service_conn()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(f"""
            SELECT ds.FelStatus, COUNT(d.IdDosar) as total, COALESCE(SUM(d.ValoareCreditRON),0) as valoare
            FROM {db}.Dosar d
            JOIN {db}.Dosar_Status ds ON d.IdStatus = ds.IdStatus
            WHERE d.Ascuns=0
            GROUP BY ds.IdStatus, ds.FelStatus
            ORDER BY total DESC
        """)
        rows = cursor.fetchall()
        for row in rows:
            for k, v in row.items():
                if isinstance(v, Decimal):
                    row[k] = float(v)
        cursor.close()
        return jsonify({"success": True, "data": rows})
    except Exception as e:
        logger.error(f"Eroare dosare-by-status: {e}")
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if conn:
            conn.close()


@admin_dashboard_bp.route("/api/dosare-by-bank", methods=["GET"])
@require_admin()
def api_dosare_by_bank():
    db = request.args.get("db", "SVN_IM")
    if db not in ALLOWED_DBS:
        return jsonify({"success": False, "error": "DB invalid"}), 400
    conn = None
    try:
        from modules.db import get_service_conn
        from decimal import Decimal
        conn = get_service_conn()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(f"""
            SELECT COALESCE(b.Banca, 'Necunoscută') as Banca,
                   COUNT(d.IdDosar) as total,
                   COALESCE(SUM(d.ValoareCreditRON),0) as valoare
            FROM {db}.Dosar d
            LEFT JOIN {db}.Banci b ON d.IdBanca = b.IdBanca
            WHERE d.Ascuns=0
            GROUP BY d.IdBanca, b.Banca
            HAVING total > 0
            ORDER BY total DESC
            LIMIT 15
        """)
        rows = cursor.fetchall()
        for row in rows:
            for k, v in row.items():
                if isinstance(v, Decimal):
                    row[k] = float(v)
        cursor.close()
        return jsonify({"success": True, "data": rows})
    except Exception as e:
        logger.error(f"Eroare dosare-by-bank: {e}")
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if conn:
            conn.close()


@admin_dashboard_bp.route("/api/top-consultants", methods=["GET"])
@require_admin()
def api_top_consultants():
    db = request.args.get("db", "SVN_IM")
    if db not in ALLOWED_DBS:
        return jsonify({"success": False, "error": "DB invalid"}), 400
    conn = None
    try:
        from modules.db import get_service_conn
        from decimal import Decimal
        conn = get_service_conn()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(f"""
            SELECT c.IdConsultant, c.NumeConsultant, COUNT(d.IdDosar) as dosare,
                   COALESCE(SUM(d.ValoareCreditRON),0) as valoare,
                   COUNT(CASE WHEN d.DataDebursare IS NOT NULL THEN 1 END) as debursate,
                   COUNT(CASE WHEN d.DataRespingere IS NOT NULL THEN 1 END) as respinse
            FROM {db}.Dosar d
            JOIN SVN_00.Consultanti c ON d.IdConsultant = c.IdConsultant
            WHERE d.Ascuns=0
            GROUP BY c.IdConsultant, c.NumeConsultant
            ORDER BY dosare DESC
            LIMIT 20
        """)
        rows = cursor.fetchall()
        for row in rows:
            for k, v in row.items():
                if isinstance(v, Decimal):
                    row[k] = float(v)
        cursor.close()
        return jsonify({"success": True, "data": rows})
    except Exception as e:
        logger.error(f"Eroare top-consultants: {e}")
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if conn:
            conn.close()


@admin_dashboard_bp.route("/api/monthly-trend", methods=["GET"])
@require_admin()
def api_monthly_trend():
    db = request.args.get("db", "SVN_IM")
    if db not in ALLOWED_DBS:
        return jsonify({"success": False, "error": "DB invalid"}), 400
    conn = None
    try:
        from modules.db import get_service_conn
        from decimal import Decimal
        conn = get_service_conn()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(f"""
            SELECT DATE_FORMAT(b.DataPrimire, '%Y-%m') as luna,
                   COUNT(DISTINCT b.IdBaza) as leads,
                   COUNT(DISTINCT d.IdDosar) as dosare,
                   COALESCE(SUM(d.ValoareCreditRON),0) as valoare
            FROM {db}.Baza b
            LEFT JOIN {db}.Dosar d ON d.IdBaza = b.IdBaza AND d.Ascuns=0
            WHERE b.Ascuns=0 AND b.DataPrimire >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
            GROUP BY luna
            ORDER BY luna ASC
        """)
        rows = cursor.fetchall()
        for row in rows:
            for k, v in row.items():
                if isinstance(v, Decimal):
                    row[k] = float(v)
        cursor.close()
        return jsonify({"success": True, "data": rows})
    except Exception as e:
        logger.error(f"Eroare monthly-trend: {e}")
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if conn:
            conn.close()


@admin_dashboard_bp.route("/api/leads-by-source", methods=["GET"])
@require_admin()
def api_leads_by_source():
    db = request.args.get("db", "SVN_IM")
    if db not in ALLOWED_DBS:
        return jsonify({"success": False, "error": "DB invalid"}), 400
    conn = None
    try:
        from modules.db import get_service_conn
        conn = get_service_conn()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(f"""
            SELECT sl.Sursa, COUNT(b.IdBaza) as total
            FROM {db}.Baza b
            JOIN {db}.SursaLead sl ON b.IdSursa = sl.IdSursa
            WHERE b.Ascuns=0
            GROUP BY sl.IdSursa, sl.Sursa
            ORDER BY total DESC
            LIMIT 15
        """)
        rows = cursor.fetchall()
        cursor.close()
        return jsonify({"success": True, "data": rows})
    except Exception as e:
        logger.error(f"Eroare leads-by-source: {e}")
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if conn:
            conn.close()


@admin_dashboard_bp.route("/api/consultants-tree", methods=["GET"])
@require_admin()
def api_consultants_tree():
    db = request.args.get("db", "SVN_IM")
    if db not in ALLOWED_DBS:
        return jsonify({"success": False, "error": "DB invalid"}), 400
    conn = None
    try:
        from modules.db import get_service_conn
        conn = get_service_conn()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(f"""
            SELECT IdConsultant, NumeConsultant, IdParinte, IdNivel, Functie
            FROM {db}.Consultanti
            WHERE Ascuns=0 AND Plecat=0
            ORDER BY IdNivel DESC, NumeConsultant
        """)
        rows = cursor.fetchall()
        cursor.close()

        # Build tree from flat list using IdParinte
        all_ids = {r["IdConsultant"] for r in rows}
        nodes = {r["IdConsultant"]: {
            "id": r["IdConsultant"],
            "label": r["NumeConsultant"],
            "IdNivel": r["IdNivel"],
            "Functie": r.get("Functie") or "",
            "children": [],
        } for r in rows}

        roots = []
        for r in rows:
            pid = r.get("IdParinte")
            if pid and pid in nodes:
                nodes[pid]["children"].append(nodes[r["IdConsultant"]])
            else:
                roots.append(nodes[r["IdConsultant"]])

        return jsonify({"success": True, "data": roots})
    except Exception as e:
        logger.error(f"Eroare consultants-tree: {e}")
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if conn:
            conn.close()


@admin_dashboard_bp.route("/api/feedback-analysis", methods=["GET"])
@require_admin()
def api_feedback_analysis():
    db = request.args.get("db", "SVN_IM")
    if db not in ALLOWED_DBS:
        return jsonify({"success": False, "error": "DB invalid"}), 400

    date_from = request.args.get("date_from", "")
    date_to = request.args.get("date_to", "")
    consultant_id = request.args.get("consultant_id", "")

    conn = None
    try:
        from modules.db import get_service_conn
        from routes.admin_modules.feedback_analyzer import analyze_consultant_feedbacks

        # Build WHERE clauses
        conditions = ["bf.Feedback IS NOT NULL", "TRIM(bf.Feedback) != ''"]
        params = []
        if date_from:
            conditions.append("bf.DataConectare >= %s")
            params.append(date_from)
        if date_to:
            conditions.append("bf.DataConectare <= %s")
            params.append(date_to)
        if consultant_id:
            try:
                conditions.append("bf.IdConsultant = %s")
                params.append(int(consultant_id))
            except (ValueError, TypeError):
                pass

        where = " AND ".join(conditions)

        conn = get_service_conn()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(f"""
            SELECT bf.IdFeedBack, bf.IdConsultant, bf.Feedback,
                   c.NumeConsultant, bs.FelStatus, bf.DataConectare
            FROM {db}.Baza_FeedBack bf
            JOIN {db}.Consultanti c ON bf.IdConsultant = c.IdConsultant
            JOIN {db}.Baza_Status bs ON bf.IdStatus = bs.IdStatus
            WHERE {where}
            ORDER BY bf.IdFeedBack DESC
        """, params if params else None)
        rows = cursor.fetchall()
        cursor.close()

        for row in rows:
            if row.get("DataConectare") and not isinstance(row["DataConectare"], str):
                row["DataConectare"] = str(row["DataConectare"])

        analysis = analyze_consultant_feedbacks(rows)
        return jsonify({"success": True, "data": analysis, "total_analyzed": len(rows)})
    except Exception as e:
        logger.error(f"Eroare feedback-analysis: {e}")
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if conn:
            conn.close()


@admin_dashboard_bp.route("/api/feedback-analysis/consultant/<int:cid>", methods=["GET"])
@require_admin()
def api_feedback_analysis_consultant(cid):
    db = request.args.get("db", "SVN_IM")
    if db not in ALLOWED_DBS:
        return jsonify({"success": False, "error": "DB invalid"}), 400
    date_from = request.args.get("date_from", "")
    date_to = request.args.get("date_to", "")
    conn = None
    try:
        from modules.db import get_service_conn
        from routes.admin_modules.feedback_analyzer import analyze_single_feedbacks

        conditions = ["bf.IdConsultant = %s",
                      "bf.Feedback IS NOT NULL", "TRIM(bf.Feedback) != ''"]
        params = [cid]
        if date_from:
            conditions.append("bf.DataConectare >= %s")
            params.append(date_from)
        if date_to:
            conditions.append("bf.DataConectare <= %s")
            params.append(date_to)
        where = " AND ".join(conditions)

        conn = get_service_conn()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(f"""
            SELECT bf.IdFeedBack, bf.Feedback, bs.FelStatus,
                   bf.DataConectare, c.NumeConsultant
            FROM {db}.Baza_FeedBack bf
            JOIN {db}.Baza_Status bs ON bf.IdStatus = bs.IdStatus
            JOIN {db}.Consultanti c ON bf.IdConsultant = c.IdConsultant
            WHERE {where}
            ORDER BY bf.IdFeedBack DESC
        """, params)
        rows = cursor.fetchall()
        cursor.close()
        for row in rows:
            if row.get("DataConectare") and not isinstance(row["DataConectare"], str):
                row["DataConectare"] = str(row["DataConectare"])
        tagged = analyze_single_feedbacks(rows)
        consultant_name = rows[0]["NumeConsultant"] if rows else f"Consultant {cid}"
        return jsonify({"success": True, "consultant": consultant_name, "data": tagged, "total": len(tagged)})
    except Exception as e:
        logger.error(f"Eroare feedback-analysis consultant {cid}: {e}")
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if conn:
            conn.close()


@admin_dashboard_bp.route("/api/feedback-by-status", methods=["GET"])
@require_admin()
def api_feedback_by_status():
    db = request.args.get("db", "SVN_IM")
    if db not in ALLOWED_DBS:
        return jsonify({"success": False, "error": "DB invalid"}), 400
    conn = None
    try:
        from modules.db import get_service_conn
        conn = get_service_conn()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(f"""
            SELECT bs.FelStatus, COUNT(bf.IdFeedBack) as total
            FROM {db}.Baza_FeedBack bf
            JOIN {db}.Baza_Status bs ON bf.IdStatus = bs.IdStatus
            GROUP BY bs.IdStatus, bs.FelStatus
            ORDER BY total DESC
            LIMIT 15
        """)
        rows = cursor.fetchall()
        cursor.close()
        return jsonify({"success": True, "data": rows})
    except Exception as e:
        logger.error(f"Eroare feedback-by-status: {e}")
        return jsonify({"success": False, "error": str(e)}), 500
    finally:
        if conn:
            conn.close()
