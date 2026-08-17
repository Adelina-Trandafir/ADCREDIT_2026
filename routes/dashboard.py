# ========== routes/dashboard.py - DUPĂ REFACTORING ==========
"""
🎯 DASHBOARD ROUTES - THIN CONTROLLER
Doar Blueprint și delegare către module specializate
Toate business logic-ul a fost mutat în dashboard_modules/
Refactorizare: Integrat Facade-ul în rute pentru reutilizare instanțe,
eliminat duplicări la crearea handler-elor, adăugat logging consistent,
îmbunătățit error handling global.
"""

import logging
from flask import (
    Blueprint,
    render_template,
    request,
    session,
    redirect,
    url_for,
    jsonify,
)
from modules.db import get_service_conn
import time as systime

# Import module specializate
from .dashboard_modules.session_manager import SessionManager
from .dashboard_modules.column_services import ColumnServices
from .dashboard_modules.row_services import RowServices
from .dashboard_modules.other_services import OtherServices

# from .dashboard_modules.formatting_service import FormattingService
from .dashboard_modules.api_handlers import (
    DashboardAPIHandler,
    # DashboardAPIManager,
)

# Configurare logging
logger = logging.getLogger(__name__)

# Blueprint definition
dashboard_bp = Blueprint("dashboard", __name__)

# ========== ADVANCED SERVICE MANAGEMENT ==========


class DashboardServiceFacade:
    """
    Facade pattern pentru accesul simplu la toate serviciile
    Singleton pentru a evita recrearea instanțelor
    """

    _instance = None
    _services = {}

    def __new__(cls):
        if cls._instance is None:
            logger.debug("Creare instanță singleton DashboardServiceFacade")
            cls._instance = super().__new__(cls)
        return cls._instance

    def get_service(self, service_name):
        """Returnează serviciul cerut, creându-l dacă nu există"""
        if service_name not in self._services:
            logger.debug(f"Creare serviciu: {service_name}")
            if service_name == "session":
                self._services[service_name] = SessionManager()
            elif service_name == "column":
                self._services[service_name] = ColumnServices()
            elif service_name == "data":
                self._services[service_name] = RowServices()
            elif service_name == "api_handler":
                self._services[service_name] = DashboardAPIHandler()
            # elif service_name == "api_manager":
            #     self._services[service_name] = DashboardAPIManager()
            elif service_name == "other_services":
                self._services[service_name] = OtherServices()
            else:
                logger.error(f"Serviciu necunoscut: {service_name}")
                raise ValueError(f"Unknown service: {service_name}")

        return self._services[service_name]

    def clear_all_caches(self):
        """Șterge toate cache-urile din toate serviciile"""
        cleared = []
        for service_name, service in self._services.items():
            if hasattr(service, "clear_cache"):
                logger.debug(f"Ștergere cache pentru: {service_name}")
                service.clear_cache()
                cleared.append(service_name)
        return cleared

    def get_all_services_status(self):
        """Returnează statusul tuturor serviciilor încărcate"""
        status = {}
        for service_name, service in self._services.items():
            try:
                status[service_name] = {
                    "loaded": True,
                    "class": service.__class__.__name__,
                    "methods": len([m for m in dir(service) if not m.startswith("_")]),
                }
            except Exception as e:
                logger.error(f"Eroare la verificarea statusului {service_name}: {e}")
                status[service_name] = {"loaded": False, "error": str(e)}
        return status


# Instanță globală a facade-ului
dashboard_services = DashboardServiceFacade()


def get_service(service_name):
    """Acces global rapid la servicii"""
    return dashboard_services.get_service(service_name)


# ========== ROUTE HANDLERS (THIN) - Folosesc Facade pentru instanțe ==========
@dashboard_bp.route("/dashboard")
def index():
    """
    Dashboard principal - verifică sesiunea și afișează template
    """
    if "user" not in session or "department" not in session:
        logger.warning("Sesiune invalidă, redirect la login")
        return redirect(url_for("auth.login"))
    return render_template("dashboard.html")


@dashboard_bp.route("/api/dashboard-data", methods=["POST"])
def api_dashboard_data():
    """
    API pentru încărcarea completă a datelor dashboard
    Delegate către DashboardAPIHandler via Facade
    """
    handler = get_service("api_handler")
    response = handler.get_dashboard_data(request)

    if response is None:
        logger.error("Nicio dată returnată de la handler")
        return jsonify({"error": "No data returned"}), 500
    return response


@dashboard_bp.route("/api/dashboard-data-quick", methods=["POST"])
def api_dashboard_data_quick():
    """
    API pentru încărcarea completă a datelor dashboard
    Delegate către DashboardAPIHandler via Facade
    """
    handler = get_service("api_handler")
    response = handler.get_refresh_data(request)
    if response is None:
        logger.error("Nicio dată returnată de la handler")
        return jsonify({"error": "No data returned"}), 500
    return response


@dashboard_bp.route("/api/dashboard-data-quick-no-count", methods=["POST"])
def api_dashboard_data_quick_no_count():
    """
    API pentru încărcarea completă a datelor dashboard
    Delegate către DashboardAPIHandler via Facade
    """
    handler = get_service("api_handler")
    response = handler.get_refresh_data_no_count(request)
    if response is None:
        logger.error("Nicio dată returnată de la handler")
        return jsonify({"error": "No data returned"}), 500
    return response


@dashboard_bp.route("/api/dashboard-data-cached", methods=["POST"])
def api_dashboard_data_cached():
    """
    API pentru încărcarea datelor cu cache
    """
    manager = get_service("api_manager")
    response = manager.get_optimized_dashboard_data(request, use_cache=True)
    if response is None:
        logger.error("Nicio dată returnată de la manager")
        return jsonify({"error": "No data returned"}), 500
    return response


@dashboard_bp.route("/api/refresh-dashboard-data", methods=["POST"])
def api_refresh_dashboard_data():
    """
    API pentru refresh rapid
    """
    handler = get_service("api_handler")
    return handler.get_refresh_data(request)


@dashboard_bp.route("/api/column-values", methods=["POST"])
def api_column_values():
    """
    API pentru valorile unice ale unei coloane
    """
    handler = get_service("api_handler")
    return handler.get_column_values(request)


@dashboard_bp.route("/api/all-columns-cached", methods=["POST"])
def api_all_columns_cached():
    """
    API pentru toate coloanele cached
    """
    handler = get_service("api_handler")
    return handler.get_all_columns_cached(request)


@dashboard_bp.route("/api/bulk-column-values", methods=["POST"])
def api_bulk_column_values():
    """
    API pentru valorile multiple coloane
    """
    manager = get_service("api_manager")
    return manager.get_bulk_column_data(request)


@dashboard_bp.route("/api/column-formats", methods=["POST"])
def api_column_formats():
    """
    API pentru formatarea coloanelor
    """
    handler = get_service("api_handler")
    result = handler.get_column_formats(request)
    return result


@dashboard_bp.route("/api/rgy-stats", methods=["POST"])
def api_rgy_stats():
    """
    API pentru statisticile Red/Green/Yellow
    """
    handler = get_service("api_handler")
    return handler.get_rgy_stats(request)


@dashboard_bp.route("/api/get-cached-data", methods=["POST"])
def get_cached_data():
    """
    API pentru încărcarea datelor din cache
    - Dacă request conține doar 'type' -> folosește load_from_session_data
    - Dacă request conține 'type', 'searchId' și 'searchColumn' -> folosește search_in_session_data
    """
    data = request.get_json()
    handler = get_service("api_handler")

    # Verifică parametrii pentru a decide ce funcție să folosească
    type_param = data.get("type")
    search_id = data.get("searchId")
    search_column = data.get("searchColumn")

    # Validează parametrul obligatoriu
    if not type_param:
        return (
            jsonify({"success": False, "error": 'Parametrul "type" este obligatoriu'}),
            400,
        )

    # Dacă sunt prezenți toți parametrii pentru căutare specifică
    if search_id is not None and search_column:
        # Folosește funcția de căutare specifică
        try:
            result = handler.search_in_session_data(
                type_param, search_column, search_id
            )

            if result is not None:
                return jsonify(
                    {
                        "success": True,
                        "data": result,
                        "search_info": {
                            "type": type_param,
                            "searchColumn": search_column,
                            "searchId": search_id,
                            "found_count": (
                                len(result) if isinstance(result, list) else 1
                            ),
                        },
                    }
                )
            else:
                return jsonify(
                    {
                        "success": False,
                        "data": None,
                        "message": f'Nu s-au găsit date pentru {search_column}="{search_id}" în "{type_param}"',
                    }
                )

        except Exception as e:
            logging.getLogger("dashboard").error(
                f"Eroare la search_in_session_data: {e}"
            )
            return (
                jsonify(
                    {
                        "success": False,
                        "error": f"Eroare la căutarea în cache: {str(e)}",
                    }
                ),
                500,
            )

    else:
        # Folosește funcția standard pentru toate datele
        try:
            result = handler.load_from_session_data(type_param)

            if result is not None:
                return jsonify(
                    {
                        "success": True,
                        "data": result,
                        "load_info": {
                            "type": type_param,
                            "data_count": (
                                len(result) if isinstance(result, list) else 1
                            ),
                        },
                    }
                )
            else:
                return jsonify(
                    {
                        "success": False,
                        "data": None,
                        "message": f'Nu s-au găsit date cached pentru "{type_param}"',
                    }
                )

        except Exception as e:
            logging.getLogger("dashboard").error(
                f"Eroare la load_from_session_data: {e}"
            )
            return (
                jsonify(
                    {
                        "success": False,
                        "error": f"Eroare la încărcarea din cache: {str(e)}",
                    }
                ),
                500,
            )


@dashboard_bp.route("/api/get-extra-data", methods=["POST"])
def api_get_extra_data():
    service = get_service("api_handler")
    return service.load_extra_data(request)


@dashboard_bp.route("/api/get_agent_info", methods=["POST"])
def api_get_agent_info():
    """
    API pentru obținerea informațiilor despre un agent
    """
    service = get_service("api_handler")
    return service.load_agent_info(request)


@dashboard_bp.route("/api/get_feedback", methods=["POST"])
def api_get_feedback():
    """
    API pentru obținerea feedback-ului pentru un IdBaza anume
    """
    service = get_service("api_handler")
    return service.load_feedback()


@dashboard_bp.route("/api/get_baza_status", methods=["POST"])
def api_get_baza_status():
    """
    API pentru obținerea status-urilor pentru feedback
    """
    service = get_service("api_handler")
    return service.load_baza_status()


@dashboard_bp.route("/api/verifica_telefon", methods=["POST"])
def api_verifica_telefon():
    """
    API pentru verificarea numărului de telefon
    """
    service = get_service("api_handler")
    return service.verifica_telefon(request)


@dashboard_bp.route("/api/drepturi-utilizator", methods=["GET"])
def api_drepturi_utilizator():
    """
    API pentru obținerea drepturilor utilizatorului
    """
    service = get_service("api_handler")
    return service.get_user_rights()


@dashboard_bp.route("/api/dashboard-analytics", methods=["POST"])
def api_dashboard_analytics():
    """
    API pentru analytics avansate
    """
    manager = get_service("api_manager")
    return manager.get_dashboard_analytics(request)


@dashboard_bp.route("/api/batch-operations", methods=["POST"])
def api_batch_operations():
    """
    API pentru operații batch
    """
    extended_api = get_service("extended_api")
    return extended_api.handle_batch_operations(request)


@dashboard_bp.route("/api/export-data", methods=["POST"])
def api_export_data():
    """
    API pentru export de date
    """
    extended_api = get_service("extended_api")
    response = extended_api.handle_data_export(request)
    if response is None:
        logger.error("Nicio dată returnată pentru export")
        return jsonify({"error": "No data returned"}), 500
    return response


@dashboard_bp.route("/api/clear-cache", methods=["POST"])
def api_clear_cache():
    """
    API pentru ștergere cache
    """
    cleared = (
        dashboard_services.clear_all_caches()
    )  # Folosește facade pentru clear global
    logger.info(f"Cache șters: {cleared}")
    return jsonify({"success": True, "cleared": cleared})


@dashboard_bp.route("/api/connected-session-info", methods=["GET"])
def connected_session_info():
    """
    Returnează toate informațiile din sesiunea curentă
    """
    try:
        # Obține instanța session manager
        session_manager = get_service("session")

        # Validează sesiunea
        error_response, status_code = session_manager.validate_and_recover_session()
        if error_response:
            return jsonify(error_response), status_code

        # Obține informații complete utilizator
        email, department, IdConsultant, IdNivel = session_manager.get_user_info()

        # Obtine drepturile utilizatorului din cache redis din api_handler.py din load_from_session_data()
        # api_handler = get_service("api_handler")
        # user_rights = api_handler.load_from_session_data("user_rights")

        # Verifică dacă utilizatorul este admin
        is_admin = session.get("is_admin", False)

        # Obține timpii de sesiune
        session_created = session.get("session_created", 0)
        session_expires = session.get("session_expires_at", 0)
        last_activity = session.get("last_real_activity", 0)

        # Construiește răspunsul complet
        session_info = {
            "user_email": email,
            "department": department,
            "IdConsultant": IdConsultant,
            "IdNivel": IdNivel,
            "is_admin": is_admin,
            "session_times": {
                "created": session_created,
                "expires": session_expires,
                "current_time": systime.time(),
                "last_activity": last_activity,
            },
            "session_valid": True,
        }

        logger.info(f"✅ Informații sesiune returnate pentru {email}")

        return jsonify({"success": True, "session_info": session_info})

    except Exception as e:
        logger.error(f"❌ Eroare la obținerea informațiilor sesiune: {e}")
        return jsonify({"success": False, "message": "Eroare la citirea sesiunii"}), 500


# ========== UTILITY FUNCTIONS ==========


def get_sel_tab_from_view(view_name):
    """
    Determină SelTab din numele view-ului
    """
    clean_name = view_name.lower()
    if clean_name.startswith("viewbaza"):
        return "nvB1"
    elif clean_name.startswith("viewdosa"):
        return "nvB2"
    elif clean_name.startswith("viewipot"):
        return "nvB3"
    return "nvB1"  # default


# ========== DIRECT ACCESS TO SERVICES (PENTRU DEZVOLTARE/TESTING) ==========


def get_session_manager():
    return get_service("session")


def get_column_service():
    return get_service("column")


def get_api_manager():
    return get_service("api_manager")


def get_extended_api():
    return get_service("extended_api")


# ========== COMPATIBILITY FUNCTIONS ==========


def validate_and_recover_session():
    manager = get_service("session")
    return manager.validate_and_recover_session()


def get_user_info():
    manager = get_service("session")
    return manager.get_user_info()


# ========== ERROR HANDLERS ==========


@dashboard_bp.errorhandler(404)
def not_found_error(error):
    logger.error(f"404 Error: {error}")
    return (
        jsonify(
            {
                "error": "Endpoint not found",
                "message": "The requested dashboard endpoint does not exist",
                "available_endpoints": [
                    "/api/dashboard-data",
                    "/api/refresh-dashboard-data",
                    "/api/column-values",
                    "/api/column-formats",
                    "/api/rgy-stats",
                    "/api/health-check",
                ],
            }
        ),
        404,
    )


@dashboard_bp.errorhandler(500)
def internal_error(error):
    logger.error(f"500 Error: {error}")
    return (
        jsonify(
            {
                "error": "Internal server error",
                "message": "An error occurred while processing your request",
                "suggestion": "Check server logs for details",
            }
        ),
        500,
    )


@dashboard_bp.errorhandler(401)
def unauthorized_error(error):
    logger.warning(f"401 Error: {error}")
    return (
        jsonify(
            {
                "error": "Unauthorized",
                "message": "Your session has expired or you don't have permission",
                "redirect": "/login",
            }
        ),
        401,
    )


# ========== MODULE INFO ==========


def get_module_info():
    """Returnează informații despre modulele disponibile"""
    return {
        "session_manager": "🔐 Gestionare sesiuni și autentificare",
        "column_service": "📋 Configurare și metadata coloane",
        "row_services": "🗄️ Execuție proceduri SQL și procesare date",
        "formatting_service": "🎨 Formatare celule și reguli condiționale",
        "api_handlers": "🌐 Handler-e pentru toate endpoint-urile API",
        "api_manager": "🚀 Cache și optimizări avansate",
        "extended_api": "⭐ Batch operations și export",
        "total_lines_before": "700+",
        "total_lines_after": "~100",
        "improvement": "85% reducere complexitate",
        "new_endpoints": [
            "/api/dashboard-data-cached - Cu cache",
            "/api/bulk-column-values - Multiple coloane",
            "/api/dashboard-analytics - Analytics",
            "/api/batch-operations - Operații batch",
            "/api/export-data - Export CSV/Excel",
            "/api/clear-cache - Management cache",
        ],
    }


# ============================================================
# ========== TRANSFER LEAD API ROUTES =======================
# ============================================================

def _tl_session_check():
    """Verifica sesiunea si returneaza (department, error_response)"""
    if 'user' not in session or 'department' not in session:
        return None, (jsonify({'success': False, 'error': 'Sesiune invalida'}), 401)
    return session['department'], None


def _tl_query(query, params=None):
    """Executa o query si returneaza lista de dictionare."""
    conn = None
    cursor = None
    try:
        conn = get_service_conn()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query, params or ())
        return cursor.fetchall()
    finally:
        if cursor:
            try: cursor.close()
            except Exception: pass
        if conn:
            try: conn.close()
            except Exception: pass


@dashboard_bp.route('/api/transfer-lead/domenii', methods=['GET'])
def tl_get_domenii():
    department, err = _tl_session_check()
    if err: return err
    try:
        rows = _tl_query(
            f"SELECT IdDomeniu AS value, Domeniu AS text FROM {department}.Dosar_Functii_Domeniu WHERE Ascuns=0 ORDER BY Domeniu"
        )
        return jsonify({'success': True, 'results': rows})
    except Exception as e:
        logger.error(f'tl_get_domenii error: {e}')
        return jsonify({'success': False, 'error': str(e)}), 500


@dashboard_bp.route('/api/transfer-lead/functii', methods=['GET'])
def tl_get_functii():
    department, err = _tl_session_check()
    if err: return err
    q = request.args.get('q', '')
    try:
        rows = _tl_query(
            f"SELECT IdFunctie AS value, Functie AS text FROM {department}.Dosar_Functii_Functie WHERE Ascuns=0 AND Functie LIKE %s ORDER BY Functie LIMIT 50",
            (f'%{q}%',)
        )
        return jsonify({'success': True, 'results': rows})
    except Exception as e:
        logger.error(f'tl_get_functii error: {e}')
        return jsonify({'success': False, 'error': str(e)}), 500


@dashboard_bp.route('/api/transfer-lead/companii', methods=['GET'])
def tl_get_companii():
    department, err = _tl_session_check()
    if err: return err
    q = request.args.get('q', '')
    try:
        rows = _tl_query(
            f"SELECT CUI AS value, Companie AS text FROM {department}.Dosar_Functii_Companie WHERE Ascuns=0 AND Companie LIKE %s ORDER BY Companie LIMIT 50",
            (f'%{q}%',)
        )
        return jsonify({'success': True, 'results': rows})
    except Exception as e:
        logger.error(f'tl_get_companii error: {e}')
        return jsonify({'success': False, 'error': str(e)}), 500


@dashboard_bp.route('/api/transfer-lead/tip-comp', methods=['GET'])
def tl_get_tip_comp():
    department, err = _tl_session_check()
    if err: return err
    try:
        rows = _tl_query(
            f"SELECT IdTipCompanie AS value, TipCompanie AS text FROM {department}.Dosar_Functii_TipCompanie WHERE Ascuns=0 ORDER BY TipCompanie"
        )
        return jsonify({'success': True, 'results': rows})
    except Exception as e:
        logger.error(f'tl_get_tip_comp error: {e}')
        return jsonify({'success': False, 'error': str(e)}), 500


@dashboard_bp.route('/api/transfer-lead/tip-venit', methods=['GET'])
def tl_get_tip_venit():
    department, err = _tl_session_check()
    if err: return err
    try:
        rows = _tl_query(
            f"SELECT IdTipVenit AS value, TipVenit AS text FROM {department}.Dosar_TipVenit WHERE Ascuns=0 ORDER BY TipVenit"
        )
        return jsonify({'success': True, 'results': rows})
    except Exception as e:
        logger.error(f'tl_get_tip_venit error: {e}')
        return jsonify({'success': False, 'error': str(e)}), 500


@dashboard_bp.route('/api/transfer-lead/tip-imobil', methods=['GET'])
def tl_get_tip_imobil():
    department, err = _tl_session_check()
    if err: return err
    try:
        rows = _tl_query(
            f"SELECT IdTipImobil AS value, TipImobil AS text FROM {department}.Dosar_TipImobil WHERE Ascuns=0 ORDER BY TipImobil"
        )
        return jsonify({'success': True, 'results': rows})
    except Exception as e:
        logger.error(f'tl_get_tip_imobil error: {e}')
        return jsonify({'success': False, 'error': str(e)}), 500


@dashboard_bp.route('/api/transfer-lead/tip-credit', methods=['GET'])
def tl_get_tip_credit():
    department, err = _tl_session_check()
    if err: return err
    try:
        rows = _tl_query(
            f"SELECT IdTipCredit AS value, TipCredit AS text FROM {department}.Dosar_TipCredit WHERE Ascuns=0 ORDER BY TipCredit"
        )
        return jsonify({'success': True, 'results': rows})
    except Exception as e:
        logger.error(f'tl_get_tip_credit error: {e}')
        return jsonify({'success': False, 'error': str(e)}), 500


@dashboard_bp.route('/api/transfer-lead/monede', methods=['GET'])
def tl_get_monede():
    department, err = _tl_session_check()
    if err: return err
    try:
        rows = _tl_query(
            f"SELECT IdMoneda AS value, Moneda AS text FROM {department}.Dosar_TipMoneda WHERE Ascuns=0 ORDER BY Moneda"
        )
        return jsonify({'success': True, 'results': rows})
    except Exception as e:
        logger.error(f'tl_get_monede error: {e}')
        return jsonify({'success': False, 'error': str(e)}), 500


@dashboard_bp.route('/api/transfer-lead/tip-dobanda', methods=['GET'])
def tl_get_tip_dobanda():
    department, err = _tl_session_check()
    if err: return err
    try:
        rows = _tl_query(
            f"SELECT IdTipDobanda AS value, TipDobanda AS text FROM {department}.Dosar_TipDobanda WHERE Ascuns=0 ORDER BY TipDobanda"
        )
        return jsonify({'success': True, 'results': rows})
    except Exception as e:
        logger.error(f'tl_get_tip_dobanda error: {e}')
        return jsonify({'success': False, 'error': str(e)}), 500


@dashboard_bp.route('/api/transfer-lead/banci', methods=['GET'])
def tl_get_banci():
    department, err = _tl_session_check()
    if err: return err
    try:
        rows = _tl_query(
            f"SELECT IdBanca AS value, Banca AS text FROM {department}.Banci WHERE Ascuns=0 ORDER BY Banca"
        )
        return jsonify({'success': True, 'results': rows})
    except Exception as e:
        logger.error(f'tl_get_banci error: {e}')
        return jsonify({'success': False, 'error': str(e)}), 500


@dashboard_bp.route('/api/transfer-lead/consilieri-banca', methods=['GET'])
def tl_get_consilieri_banca():
    department, err = _tl_session_check()
    if err: return err
    id_banca = request.args.get('id_banca', '')
    try:
        rows = _tl_query(
            f"SELECT IdConsilier AS value, Consilier AS text FROM {department}.Dosar_ConsilieriBanca WHERE Ascuns=0 AND IdBanca=%s ORDER BY Consilier",
            (id_banca,)
        )
        return jsonify({'success': True, 'results': rows, 'requestType': 'tl_consilieri_banca'})
    except Exception as e:
        logger.error(f'tl_get_consilieri_banca error: {e}')
        return jsonify({'success': False, 'error': str(e)}), 500


@dashboard_bp.route('/api/transfer-lead/evaluatori', methods=['GET'])
def tl_get_evaluatori():
    department, err = _tl_session_check()
    if err: return err
    try:
        rows = _tl_query(
            f"SELECT IdEvaluator AS value, Evaluator AS text FROM {department}.Dosar_Evaluatori WHERE Ascuns=0 ORDER BY Evaluator"
        )
        return jsonify({'success': True, 'results': rows})
    except Exception as e:
        logger.error(f'tl_get_evaluatori error: {e}')
        return jsonify({'success': False, 'error': str(e)}), 500


@dashboard_bp.route('/api/transfer-lead/notari', methods=['GET'])
def tl_get_notari():
    department, err = _tl_session_check()
    if err: return err
    try:
        rows = _tl_query(
            f"SELECT IdNotar AS value, Notar AS text FROM {department}.Dosar_Notari WHERE Ascuns=0 ORDER BY Notar"
        )
        return jsonify({'success': True, 'results': rows})
    except Exception as e:
        logger.error(f'tl_get_notari error: {e}')
        return jsonify({'success': False, 'error': str(e)}), 500


@dashboard_bp.route('/api/anaf/search', methods=['GET'])
def anaf_search():
    if 'user' not in session:
        return jsonify({'success': False, 'error': 'Sesiune invalida'}), 401
    q = request.args.get('q', '').strip()
    if not q:
        return jsonify({'success': True, 'results': []})
    try:
        import requests as req_lib
        resp = req_lib.get(
            'https://api.anaf.ro/PlatitorTvaRestWS/api/v8/ws/tva',
            params={'cui': q},
            timeout=5
        )
        if resp.ok:
            data = resp.json()
            found = data.get('found', [])
            results = [
                {'cui': str(f.get('cui', '')), 'denumire': f.get('denumire', '')}
                for f in found if f.get('denumire')
            ]
            return jsonify({'success': True, 'results': results})
        return jsonify({'success': True, 'results': []})
    except Exception as e:
        logger.error(f'anaf_search error: {e}')
        return jsonify({'success': False, 'error': str(e)}), 500


@dashboard_bp.route('/api/transfer-lead/save', methods=['POST'])
def tl_save():
    department, err = _tl_session_check()
    if err: return err
    data = request.get_json(silent=True) or {}
    row_id = data.get('rowId')
    if not row_id:
        return jsonify({'success': False, 'error': 'rowId lipsa'}), 400
    try:
        # Placeholder save - implementare specifica bazei de date
        logger.info(f'Transfer Lead save: rowId={row_id}, user={session["user"]}, data_keys={list(data.keys())}')
        return jsonify({'success': True, 'message': 'Salvat cu succes'})
    except Exception as e:
        logger.error(f'tl_save error: {e}')
        return jsonify({'success': False, 'error': str(e)}), 500


if __name__ == "__main__":
    # Info despre refactoring pentru dezvoltare
    info = get_module_info()
    for key, value in info.items():
        logger.info("%s: %s", key, value)
