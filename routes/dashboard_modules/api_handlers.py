# ========== routes/dashboard_modules/api_handlers.py ==========
"""
🌐 API HANDLERS MODULE
Orchestrează toate apelurile API pentru dashboard
Responsabilități:
- Primește request-urile de la Flask routes
- Orchestrează apelurile către servicii
- Returnează răspunsuri formatate JSON
- Gestionare centralizată a erorilor
"""

from flask import jsonify, make_response, session
from typing import cast, Any, Optional

# from routes.dashboard import get_service
from .session_manager import SessionManager
from .column_services import ColumnServices

# from .formatting_service import FormattingService
from routes.dashboard_modules.row_services import RowServices

from routes.dashboard_modules.other_services import OtherServices
import time
import logging
import json
from routes.auth import redis_client

SESSION_KEY = "session_data_id"
REDIS_PREFIX = "session_data:"


class DashboardAPIHandler:
    """Orchestrator pentru toate API-urile dashboard"""

    def __init__(self):
        # Inițializează toate serviciile
        self.session_manager = SessionManager()
        self.column_service = ColumnServices()
        self.row_services = RowServices()
        self.other_services = OtherServices()
        # self.formatting_service = FormattingService()

    def save_to_session_data(self, name: str, obj, expire_sec: int = 300):
        """Salvează un obiect sub-cheia `name` în Redis"""

        def json_serial(obj):
            """JSON serializer pentru obiecte care nu sunt serializabile implicit"""
            from datetime import time as time_type  # Import local
            from datetime import date, datetime
            from decimal import Decimal

            if isinstance(obj, datetime):
                return obj.strftime("%Y-%m-%d %H:%M:%S")
            if isinstance(obj, date):
                return obj.strftime("%Y-%m-%d")
            if isinstance(obj, time_type):
                return obj.strftime("%H:%M:%S")
            if isinstance(obj, Decimal):
                return float(obj)
            if isinstance(obj, bytes):
                return obj.decode("utf-8", errors="ignore")
            # Pentru orice altceva, încearcă conversia la string
            try:
                return str(obj)
            except:
                return None

        session_id = self._get_or_create_session_id()
        key = f"{REDIS_PREFIX}{session_id}"

        raw_data = redis_client.get(key)
        if raw_data is None:
            data_dict = {}
        else:
            data_dict = json.loads(raw_data)

        data_dict[name] = obj

        # Serializează cu handler custom
        redis_client.setex(key, expire_sec, json.dumps(data_dict, default=json_serial))

    def load_from_session_data(self, name: str):
        """Încărcă obiectul salvat anterior sub numele `name`"""
        session_id = session.get(SESSION_KEY)
        if not session_id:
            return None

        key = f"{REDIS_PREFIX}{session_id}"

        # ✅ Verifică dacă cheia există și are TTL valid
        ttl = redis_client.ttl(key)
        if ttl is None or ttl <= 0:
            # 🔴 Cheia nu există sau a expirat
            if redis_client.exists(key):
                redis_client.delete(key)  # șterge dacă există dar e expirată
            return None

        raw_data = redis_client.get(key)  # 👈 redenumit aici
        if not raw_data:
            return None

        data_dict = json.loads(raw_data)
        return data_dict.get(name)

    def search_in_session_data(self, name: str, search_column: str, search_id):
        """
        Caută în datele salvate în Redis și returnează toate rândurile care corespund criteriului

        Args:
            name: Numele cheii din Redis (același ca la load_from_session_data)
            search_column: Numele coloanei în care să caute (doar string)
            search_id: Valoarea de căutat

        Returns:
            List: Lista cu toate rândurile găsite sau None dacă nu există date sau nu găsește nimic
        """
        try:
            # Încarcă datele folosind funcția existentă
            cached_data = self.load_from_session_data(name)

            # Verifică dacă există date în cache
            if cached_data is None:
                logging.getLogger("api_handlers").info(
                    f"🔍 search_in_session_data: Nu există date pentru cheia '{name}'"
                )
                return None

            # Asigură-te că lucrezi cu o listă
            if not isinstance(cached_data, list):
                cached_data = [cached_data] if cached_data else []

            if not cached_data:
                return None

            # Lista pentru rezultatele filtrate
            filtered_results = []

            # Analizează primul element pentru a determina structura datelor
            first_item = cached_data[0]

            if isinstance(first_item, dict):
                # 📋 DATE STRUCTURATE CA DICȚIONARE
                for item in cached_data:
                    if isinstance(item, dict) and search_column in item:
                        # Compară valorile ca string pentru siguranță
                        if str(item[search_column]) == str(search_id):
                            filtered_results.append(item)

            elif isinstance(first_item, (list, tuple)):
                # 📋 DATE STRUCTURATE CA LISTE/TUPLE
                # Pentru liste/tuple nu putem căuta după nume de coloană
                # În acest caz returnează None și loghează situația
                logging.getLogger("api_handlers").warning(
                    f"⚠️ search_in_session_data: Datele pentru '{name}' sunt liste/tuple, "
                    f"nu pot căuta după coloana '{search_column}'. Folosește index numeric."
                )
                return None

            else:
                # 📋 DATE SIMPLE (string, int, etc)
                # Pentru date simple comparăm direct cu search_id
                for item in cached_data:
                    if str(item) == str(search_id):
                        filtered_results.append(item)

            # Returnează rezultatele
            if filtered_results:
                logging.getLogger("api_handlers").info(
                    f"🎯 search_in_session_data: Găsite {len(filtered_results)} rânduri în '{name}' "
                    f"pentru {search_column}='{search_id}'"
                )
                return filtered_results
            else:
                logging.getLogger("api_handlers").info(
                    f"❌ search_in_session_data: Nu s-au găsit rânduri în '{name}' "
                    f"pentru {search_column}='{search_id}'"
                )
                return None

        except Exception as e:
            logging.getLogger("api_handlers").error(
                f"💥 Eroare în search_in_session_data pentru '{name}': {e}"
            )
            return None

    def get_all_columns_cached(self, request):
        """
        Handler pentru /api/all-columns-chached
        Returnează toate coloanele cached

        Args:
            request: Flask request object

        Returns:
            Flask Response: JSON cu toate coloanele
        """
        try:
            # Validare sesiune
            error_response, status_code = (
                self.session_manager.validate_and_recover_session()
            )
            if error_response:
                return make_response(jsonify(error_response), status_code)

            # Încarcă configurația completă a coloanelor
            email, departament, id_consultant, _ = self.session_manager.get_user_info()
            if not email:
                return self._error_response("Utilizatorul nu există în sistem.", 404)

            return make_response(
                jsonify(
                    {
                        "success": True,
                        "all_columns": self.load_from_session_data(
                            "all_columns_mapping"
                        ),
                    }
                ),
                200,
            )

        except Exception as e:
            logging.getLogger("api_handlers").info(
                f"💥 Eroare la încărcarea coloanelor: {e}"
            )
            return self._error_response(f"Eroare: {str(e)}", 500)

    def get_dashboard_data(self, request):
        """
        Handler pentru /api/dashboard-data
        Încărcare completă cu formatare și procesare coloane

        Args:
            request: Flask request object

        Returns:
            Flask Response: JSON cu date complete
        """
        try:
            logging.getLogger("api_handlers").info(
                "🚀 START get_dashboard_data - încărcare completă..."
            )

            # 1️⃣ Validare sesiune
            error_response, status_code = (
                self.session_manager.validate_and_recover_session()
            )
            if error_response:
                logging.getLogger("api_handlers").info(
                    f"❌ Validare sesiune eșuată: {error_response}"
                )
                return make_response(jsonify(error_response), status_code)

            # 2️⃣ Extrage parametrii din request
            data = request.get_json()
            if data is None:
                logging.getLogger("api_handlers").info("❌ Request fără JSON body")
                return self._error_response("Body-ul trebuie să fie JSON.", 400)

            params = self._extract_dashboard_params(data)
            # logging.getLogger("api_handlers").info(f"🔧 Parametrii extrași: {params}")

            # 3️⃣ Obține informații utilizator
            email, departament, id_consultant, id_nivel = (
                self.session_manager.get_user_info()
            )
            if not email:
                logging.getLogger("api_handlers").info(
                    "❌ Utilizator nu există în sistem"
                )
                return self._error_response("Utilizatorul nu există în sistem.", 404)

            # 4️⃣ Determină tipul de tab
            sel_tab = self._get_sel_tab_from_view(params["view_name"])

            # Incarca drepturile utilizatorului
            drepturi = self.other_services.get_user_rights(id_consultant)

            # 5️⃣ Încarcă configurația completă a coloanelor
            column_config = self.column_service.load_complete_configuration(
                departament, id_consultant, sel_tab
            )
            allowed_columns = column_config["allowed_columns"]
            all_columns = column_config["all_columns"]
            conditional_formats = column_config["columns_FC"]

            logging.getLogger("api_handlers").info(
                f"🎨 Color rules: {len(conditional_formats)} coloane cu reguli condiționale"
            )

            # 7️⃣ Execută procedura principală pentru date
            raw_data = self.row_services.execute_main_procedure_safe(
                departament,
                id_consultant,
                id_nivel,
                params["view_name"],
                params["filtru"],
                params["sort_clause"],
                params["id_cautat"],
                (
                    int(params["max_records"])
                    if params["max_records"] is not None
                    else 200
                ),
            )
            logging.getLogger("api_handlers").info(
                f"📊 Date brute: {len(raw_data['rows'])} rânduri, {len(raw_data['columns'])} coloane"
            )

            # 8️⃣ Procesează datele cu formatare completă
            # ATENȚIE: process_data_rows() așteaptă color_rules, nu column_formats!
            processed_data = self.row_services.process_data_rows(
                raw_data["rows"], allowed_columns, sel_tab
            )
            logging.getLogger("api_handlers").info(
                f"⚙️ Date procesate: {len(processed_data)} rânduri"
            )

            # 9️⃣ Calculează statistici RGY
            stats = self.row_services.execute_count_procedure(
                departament,
                id_consultant,
                id_nivel,
                params["view_name"],
                params["filtru"],
            )
            logging.getLogger("api_handlers").info(f"📈 Statistici RGY: {stats}")

            # 🔟 Construiește răspunsul complet
            response_data = {
                "success": True,
                "rowsData": processed_data,
                "columnsData": allowed_columns,  # Coloanele brute
                "statsData": stats,
                "allData": raw_data["rows"],
                "allColumns": all_columns,
                "conditionalFormats": conditional_formats,
                "rights": drepturi,
                "department": departament,
                "timestamp": int(time.time()),
            }

            self.save_to_session_data("allowed_columns", allowed_columns)
            self.save_to_session_data("columns_order", column_config["columns_order"])
            self.save_to_session_data("color_rules", conditional_formats)
            self.save_to_session_data("all_data", raw_data["rows"])
            self.save_to_session_data("all_columns", all_columns)
            self.save_to_session_data("user_rights", drepturi)

            return make_response(jsonify(response_data), 200)

        except Exception as e:
            logging.getLogger("api_handlers").info(
                f"💥 EROARE în get_dashboard_data: {e}"
            )
            import traceback

            traceback.print_exc()
            return self._error_response(
                f"Eroare la încărcarea dashboard: {str(e)}", 500
            )

    def get_refresh_data(self, request):
        """
        Handler pentru /api/refresh-dashboard-data
        Refresh rapid cu ACELAȘI output ca get_dashboard_data,
        dar fără reîncărcarea configurației coloanelor
        """
        try:
            logging.getLogger("api_handlers").info(
                "🚀 START get_refresh_data - refresh rapid cu format complet..."
            )

            # 1️⃣ Validare sesiune
            error_response, status_code = (
                self.session_manager.validate_and_recover_session()
            )
            if error_response:
                logging.getLogger("api_handlers").info(
                    f"❌ Validare sesiune eșuată: {error_response}"
                )
                return make_response(jsonify(error_response), status_code)

            # 2️⃣ Extrage parametrii din request
            data = request.get_json()
            if data is None:
                logging.getLogger("api_handlers").info("❌ Request fără JSON body")
                return self._error_response("Body-ul trebuie să fie JSON.", 400)

            params = self._extract_dashboard_params(
                data
            )  # Folosim aceiași parametri ca dashboard

            # 3️⃣ Obține informații utilizator
            email, departament, id_consultant, id_nivel = (
                self.session_manager.get_user_info()
            )
            if not email:
                logging.getLogger("api_handlers").info(
                    "❌ Utilizator nu există în sistem"
                )
                return self._error_response("Utilizatorul nu există în sistem.", 404)

            # 4️⃣ Determină tipul de tab
            sel_tab = self._get_sel_tab_from_view(params["view_name"])
            logging.getLogger("api_handlers").info(
                f"🔧 REFRESH API - View: {params['view_name']} -> SelTab: {sel_tab}"
            )

            # 7️⃣ Execută procedura principală pentru date (ACELAȘI cod ca dashboard)
            raw_data = self.row_services.execute_main_procedure_safe(
                departament,
                id_consultant,
                id_nivel,
                params["view_name"],
                params["filtru"],
                params["sort_clause"],
                params["id_cautat"],
                (
                    int(params["max_records"])
                    if params["max_records"] is not None
                    else 200
                ),
            )
            logging.getLogger("api_handlers").info(
                f"📊 Date brute refresh: {len(raw_data['rows'])} rânduri, {len(raw_data['columns'])} coloane"
            )

            allowed_columns = self.load_from_session_data("allowed_columns")

            # 8️⃣ Procesează datele cu formatare completă (ACELAȘI cod ca dashboard)
            processed_data = self.row_services.process_data_rows(
                raw_data["rows"], allowed_columns, sel_tab
            )
            logging.getLogger("api_handlers").info(
                f"⚙️ Date procesate refresh: {len(processed_data)} rânduri"
            )

            # 9️⃣ Calculează statistici RGY (ACELAȘI cod ca dashboard)
            stats = self.row_services.execute_count_procedure(
                departament,
                id_consultant,
                id_nivel,
                params["view_name"],
                params["filtru"],
            )
            logging.getLogger("api_handlers").info(
                f"📈 Statistici RGY refresh: {stats}"
            )

            # Salvează datele brute în sesiune
            self.save_to_session_data("all_data", raw_data["rows"])

            # 🔟 Construiește răspunsul IDENTIC cu get_dashboard_data
            response_data = {
                "success": True,
                "rowsData": processed_data,
                "statsData": stats,
                "departament": departament,
                "view": params["view_name"],
                "optimized_refresh": True,
                "timestamp": int(time.time()),
            }

            logging.getLogger("api_handlers").info(
                "✅ get_refresh_data COMPLETAT cu succes - format identic cu dashboard"
            )
            return make_response(jsonify(response_data), 200)

        except Exception as e:
            logging.getLogger("api_handlers").info(
                f"💥 EROARE în get_refresh_data: {e}"
            )
            import traceback

            traceback.print_exc()
            return self._error_response(f"Eroare la refresh dashboard: {str(e)}", 500)

    def get_column_values(self, request):
        """
        Handler pentru /api/column-values
        Returnează valorile unice pentru dropdown-ul de filtrare

        Args:
            request: Flask request object

        Returns:
            Flask Response: JSON cu valorile unice
        """
        try:
            # Validare sesiune
            error_response, status_code = (
                self.session_manager.validate_and_recover_session()
            )
            if error_response:
                return make_response(jsonify(error_response), status_code)

            data = request.get_json()

            logging.getLogger("api_handlers").info(f"DATA: {data}")

            column_field = data.get("column")
            filtru = data.get("filtru")
            primarykey = data.get("PK")
            view = self._get_view_from_seltab(data.get("tab", ""), "_2025", True)
            otherFilters = data.get("otherFilters")
            BaseTable = data.get("NumeTabel")

            if not view:
                return self._error_response("Lipsește parametrul column", 400)

            if not column_field:
                return self._error_response("Lipsește parametrul column", 400)

            email, departament, _, _ = self.session_manager.get_user_info()

            if not email:
                return self._error_response("Utilizatorul nu există în sistem.", 404)

            # logging.getLogger("api_handlers").info(
            #     departament, column_field, primarykey, filtru, view
            # )

            # Delegate către column service
            values = self.column_service.get_unique_column_values(
                departament,
                column_field,
                primarykey,
                filtru,
                view,
                otherFilters,
                BaseTable,
            )

            return make_response(jsonify({"values": values}), 200)

        except Exception as e:
            logging.getLogger("api_handlers").info(
                f"❌ Eroare la încărcarea valorilor: {e}"
            )
            return self._error_response(str(e), 500)

    def get_rgy_stats(self, request):
        """
        Handler pentru /api/rgy-stats
        Returnează statisticile Red/Green/Yellow

        Args:
            request: Flask request object

        Returns:
            Flask Response: JSON cu statisticile
        """
        try:
            # Validare sesiune
            error_response, status_code = (
                self.session_manager.validate_and_recover_session()
            )
            if error_response:
                return make_response(jsonify(error_response), status_code)

            data = request.get_json() or {}
            view = data.get("view", "viewBaza_2025")
            filtru = data.get("filtru", "")

            _, departament, id_consultant, id_nivel = (
                self.session_manager.get_user_info()
            )
            if not departament:
                return self._error_response("User not found", 404)

            # Delegate către data service
            stats = self.row_services.execute_count_procedure(
                departament, id_consultant, id_nivel, view, filtru
            )

            return make_response(jsonify({"success": True, "stats": stats}), 200)

        except Exception as e:
            return self._error_response(str(e), 500)

    def get_user_rights(self):
        """
        Handler pentru /api/drepturi-utilizator
        Returnează drepturile utilizatorului curent
        Args:
            request: Flask request object
        Returns:
            Flask Response: JSON cu drepturile utilizatorului
        """
        try:
            # Validare sesiune
            error_response, status_code = (
                self.session_manager.validate_and_recover_session()
            )
            if error_response:
                return make_response(jsonify(error_response), status_code)

            _, _, id_consultant, _ = self.session_manager.get_user_info()
            if not id_consultant:
                return self._error_response("User not found", 404)

            # Caută drepturile în cache
            drepturi_cache = self.load_from_session_data("user_rights")
            if drepturi_cache is not None:
                return make_response(
                    jsonify({"success": True, "rights": drepturi_cache}), 200
                )

            # Dacă nu sunt în cache, încarcă-le din serviciu
            # Delegate către row service
            drepturi = self.other_services.get_user_rights(id_consultant)

            # Salvează în cache pentru viitor
            self.save_to_session_data("user_rights", drepturi)

            return make_response(jsonify({"success": True, "rights": drepturi}), 200)

        except Exception as e:
            return self._error_response(str(e), 500)

    def load_extra_data(self, request):
        """Handler pentru /api/get_extra_data
        Returnează rezultatul interogării de pe server și salvează în Redis

        Args:
            request (Flask Request): Request object din Flask

        Example:
            {
                "data": {
                    // === PARAMETRI OBLIGATORII ===
                    "endpoint": "get_feedback",        // Numele funcției de apelat

                    // === PARAMETRI DE CONTROL (OPȚIONALI) ===
                    "requestType": "feedback",          // Numele cheii în Redis (default: endpoint fără "get_")
                    "cache": true,                      // true = verifică cache | false = descarcă mereu (default: true)
                    "saveMode": "append",               // "append" = adaugă | "replace" = înlocuiește (default: "replace")

                    // === PARAMETRI PENTRU CĂUTARE ÎN CACHE (OPȚIONALI) ===
                    "searchColumn": "IdBaza",           // Numele coloanei în care cauți
                    "searchValue": 123,                 // Valoarea de căutat în searchColumn
                    "idColumn": "IdFeedback",           // Coloana pentru verificare unicitate la append

                    // === PARAMETRI PENTRU FUNCȚIA DE PE SERVER ===
                    "IdBaza": 123,                      // Valoare pentru searchColumn ȘI parametru pentru funcție
                    "department": "SVN_05",             // Alt parametru pentru funcție
                    // ... orice alți parametri necesari funcției

                    // === PARAMETRI IGNORAȚI (dar pot fi trimiși) ===
                    "timeout": 10000                    // Folosit de JavaScript, ignorat de Python
                }
            }
        """
        try:
            # Validare sesiune
            error_response, status_code = (
                self.session_manager.validate_and_recover_session()
            )
            if error_response:
                return make_response(jsonify(error_response), status_code)

            # 🎯 OBȚINE DATELE JSON DIN REQUEST
            request_json = request.get_json()
            if not request_json:
                return self._error_response("Cerere nevalidă: lipsă date JSON", 400)

            # 🎯 PARSARE CORECTĂ A REQUEST-ULUI
            request_data = (
                request_json.get("data", {}) if isinstance(request_json, dict) else {}
            )

            # Obține parametrii din request
            endpoint = request_data.get("endpoint", "")
            request_type = request_data.get("requestType", "")
            save_mode = request_data.get("saveMode", "replace")
            id_column = request_data.get("idColumn", None)
            use_cache = request_data.get("cache", True)  # Default: folosește cache
            search_column = request_data.get("searchColumn", None)
            search_value = request_data.get(
                "searchValue", None
            )  # 🆕 Valoarea de căutat

            # 🆕 DETERMINĂ VALOAREA DE CĂUTAT
            # if search_column and search_column in request_data:
            #     # Folosește searchColumn pentru a găsi valoarea
            #     search_id = request_data[search_column]
            #     # Dacă nu avem idColumn setat, folosește searchColumn și pentru identificare
            #     if not id_column:
            #         id_column = search_column

            #     logging.getLogger("api_handlers").info(
            #         f"🔍 Căutare configurată: {search_column}={search_id}"
            #     )

            if not endpoint:
                return self._error_response(
                    "Cerere nevalidă: lipsă endpoint în data", 400
                )

            # 🎯 MAPARE ENDPOINT → FUNCȚIE
            endpoint_map = {
                "get_judete": self.other_services.load_judete,
                "get_surse_agenti": self.other_services.load_surse_agenti,
                "get_feedback": self.other_services.load_feedback,
                "get_consultanti": self.other_services.load_consultanti,
                "get_baza_status": self.other_services.load_baza_status,
                "verifica_telefon": self.other_services.verifica_telefon,
            }

            if endpoint not in endpoint_map:
                return self._error_response(f"Endpoint necunoscut: {endpoint}", 400)

            # 🆕 GENEREAZĂ CHEIA REDIS
            redis_key = endpoint.replace("get_", "")
            if request_type:
                redis_key = request_type

            # 🔍 VERIFICĂ CACHE-UL DACĂ use_cache = True
            if use_cache:
                cached_data = self._check_cache_for_extra_data(
                    redis_key, search_column, search_value
                )

                if cached_data is not None:
                    logging.getLogger("api_handlers").info(
                        f"✅ Cache HIT pentru {redis_key}"
                        + (
                            f" cu {search_column or id_column}={search_value}"
                            if search_value
                            else ""
                        )
                    )

                    # Returnează datele din cache
                    return make_response(
                        jsonify(
                            {
                                "success": True,
                                "results": cached_data,
                                "endpoint": endpoint,
                                "requestType": request_type,
                                "fromCache": True,
                                "message": f"Date încărcate din cache pentru {endpoint}",
                            }
                        ),
                        200,
                    )
                else:
                    logging.getLogger("api_handlers").info(
                        f"❌ Cache MISS pentru {redis_key}"
                        + (
                            f" cu {search_column or id_column}={search_value}"
                            if search_value
                            else ""
                        )
                    )

            # 📥 DESCARCĂ DATELE DE PE SERVER (cache miss sau cache: false)
            logging.getLogger("api_handlers").info(
                f"📥 Descarc date de pe server pentru {endpoint}"
                + (" (cache dezactivat)" if not use_cache else " (cache miss)")
            )

            # Prepară parametrii pentru funcție (exclude parametrii de control)
            function_params = {
                key: value
                for key, value in request_data.items()
                if key
                not in [
                    "endpoint",
                    "requestType",
                    "cache",
                    "timeout",
                    "saveMode",
                    "idColumn",
                    "searchColumn",
                    "searchValue",
                ]
            }

            # Execută funcția
            result = endpoint_map[endpoint](**function_params)

            # 💾 SALVEAZĂ ÎN REDIS
            if use_cache or save_mode == "replace":
                # Dacă cache: false, întotdeauna înlocuiește
                if not use_cache:
                    save_mode = "replace"

                logging.getLogger("api_handlers").info(
                    f"💾 Salvare în Redis - Cheie: {redis_key}, Mod: {save_mode}"
                )

                if save_mode == "append":
                    self._append_extra_data_to_redis(redis_key, result, id_column)
                else:
                    self.save_to_session_data(redis_key, result)

            # 🎯 RETURNEAZĂ REZULTATUL
            return make_response(
                jsonify(
                    {
                        "success": True,
                        "results": result,
                        "endpoint": endpoint,
                        "requestType": request_type,
                        "fromCache": False,
                        "saveMode": save_mode,
                        "searchColumn": search_column,  # 🆕 Returnăm și coloana de căutare
                        "searchValue": search_value,  # 🆕 Și valoarea căutată
                        "message": f"Date încărcate de pe server pentru {endpoint}",
                    }
                ),
                200,
            )

        except Exception as e:
            logging.getLogger("api_handlers").error(
                f"💥 Eroare la încărcarea datelor extra: {e}"
            )
            import traceback

            traceback.print_exc()
            return self._error_response(f"Eroare: {str(e)}", 500)

    # ========== HELPER METHODS ==========
    def _get_or_create_session_id(self):
        if SESSION_KEY not in session:
            import uuid

            session[SESSION_KEY] = str(uuid.uuid4())
        return session[SESSION_KEY]

    def _check_cache_for_extra_data(
        self, key_name: str, id_column=None, search_id=None
    ):
        """Verifică dacă datele există în cache și opțional dacă ID-ul specific există

        Args:
            key_name: Numele cheii Redis
            id_column: Numele/indexul coloanei ID
            search_id: Valoarea ID-ului de căutat

        Returns:
            - Datele din cache dacă există (toate sau filtrate)
            - None dacă nu există în cache
        """
        try:
            # Încarcă datele din Redis
            cached_data = self.load_from_session_data(key_name)

            # Nu există date în cache
            if cached_data is None:
                return None

            # Dacă nu trebuie să verificăm un ID specific, returnează toate datele
            if not id_column or search_id is None:
                logging.getLogger("api_handlers").info(
                    f"🔍 Cache check: {key_name} - Returnez toate datele"
                )
                return cached_data

            # 🔍 VERIFICĂ DACĂ ID-UL SPECIFIC EXISTĂ
            # Asigură-te că lucrezi cu o listă
            if not isinstance(cached_data, list):
                cached_data = [cached_data] if cached_data else []

            if not cached_data:
                return None

            # Determină metoda de extragere a ID-ului
            first_item = cached_data[0]
            filtered_data = []

            if isinstance(first_item, dict):
                # Date ca dicționare
                for item in cached_data:
                    if isinstance(item, dict):
                        item_id = item.get(
                            id_column
                            if isinstance(id_column, str)
                            else list(item.keys())[0]
                        )
                        if str(item_id) == str(search_id):
                            filtered_data.append(item)

            elif isinstance(first_item, (list, tuple)):
                # Date ca liste/tuple
                idx = 0  # default prima coloană
                if isinstance(id_column, int):
                    idx = id_column
                elif isinstance(id_column, str) and id_column.isdigit():
                    idx = int(id_column)

                for item in cached_data:
                    if isinstance(item, (list, tuple)) and len(item) > idx:
                        if str(item[idx]) == str(search_id):
                            filtered_data.append(item)
            else:
                # Date simple
                for item in cached_data:
                    if str(item) == str(search_id):
                        filtered_data.append(item)

            # Returnează datele filtrate dacă s-au găsit, altfel None
            if filtered_data:
                logging.getLogger("api_handlers").info(
                    f"🎯 Cache HIT specific: {key_name} - ID={search_id} găsit ({len(filtered_data)} înregistrări)"
                )
                return filtered_data
            else:
                logging.getLogger("api_handlers").info(
                    f"❌ Cache MISS specific: {key_name} - ID={search_id} nu există"
                )
                return None

        except Exception as e:
            logging.getLogger("api_handlers").warning(
                f"⚠️ Eroare la verificarea cache pentru {key_name}: {e}"
            )
            return None

    def _append_extra_data_to_redis(self, key_name: str, new_data, id_column=None):
        """Adaugă date în Redis doar dacă ID-urile sunt diferite

        Args:
            key_name: Numele cheii Redis (fără prefix)
            new_data: Datele noi de adăugat
            id_column: Numele/indexul coloanei care conține ID-ul unic
        """
        try:
            # Încarcă datele existente din Redis
            existing_data = self.load_from_session_data(key_name)

            if existing_data is None:
                # Prima salvare - nu există date anterioare
                self.save_to_session_data(key_name, new_data)
                logging.getLogger("api_handlers").info(
                    f"✅ Prima salvare pentru {key_name}: {len(new_data) if isinstance(new_data, list) else 1} înregistrări"
                )
                return

            # Asigură-te că lucrezi cu liste
            if not isinstance(existing_data, list):
                existing_data = [existing_data] if existing_data else []

            if not isinstance(new_data, list):
                new_data = [new_data] if new_data else []

            # Dacă nu avem date noi, ieși
            if not new_data:
                logging.getLogger("api_handlers").info(
                    f"ℹ️ Nu sunt date noi pentru {key_name}"
                )
                return

            # Determină metoda de extragere a ID-ului
            first_item = new_data[0] if new_data else None
            if not first_item:
                return

            # Funcție pentru extragerea ID-ului bazată pe tipul de date
            if isinstance(first_item, dict):
                # Date ca dicționare
                if id_column and id_column in first_item:
                    get_id = lambda item: (
                        item.get(id_column) if isinstance(item, dict) else None
                    )
                else:
                    # Prima cheie din dicționar ca ID implicit
                    first_key = list(first_item.keys())[0] if first_item else None
                    get_id = lambda item: (
                        item.get(first_key)
                        if isinstance(item, dict) and first_key
                        else None
                    )

            elif isinstance(first_item, (list, tuple)):
                # Date ca liste/tuple
                if isinstance(id_column, int):
                    # id_column este index numeric
                    get_id = lambda item: (
                        item[id_column]
                        if isinstance(item, (list, tuple)) and len(item) > id_column
                        else None
                    )
                elif isinstance(id_column, str) and id_column.isdigit():
                    # id_column este string numeric
                    idx = int(id_column)
                    get_id = lambda item: (
                        item[idx]
                        if isinstance(item, (list, tuple)) and len(item) > idx
                        else None
                    )
                else:
                    # Prima coloană ca ID implicit
                    get_id = lambda item: (
                        item[0]
                        if isinstance(item, (list, tuple)) and len(item) > 0
                        else None
                    )
            else:
                # Date simple (string, number, etc.)
                get_id = lambda item: item

            # Creează un set cu ID-urile existente pentru verificare rapidă
            existing_ids = set()
            for item in existing_data:
                try:
                    item_id = get_id(item)
                    if item_id is not None:
                        existing_ids.add(
                            str(item_id)
                        )  # Convertește la string pentru comparație uniformă
                except Exception:
                    continue

            # Adaugă doar elementele cu ID-uri noi
            items_added = 0
            items_skipped = 0

            for item in new_data:
                try:
                    item_id = get_id(item)
                    if item_id is not None:
                        if str(item_id) not in existing_ids:
                            existing_data.append(item)
                            existing_ids.add(str(item_id))
                            items_added += 1
                        else:
                            items_skipped += 1
                except Exception as e:
                    logging.getLogger("api_handlers").warning(
                        f"⚠️ Nu pot extrage ID din item: {e}"
                    )
                    continue

            # Salvează datele actualizate înapoi în Redis
            self.save_to_session_data(key_name, existing_data)

            logging.getLogger("api_handlers").info(
                f"📊 Append Redis - Cheie: {key_name} | "
                f"Existente: {len(existing_data) - items_added} | "
                f"Adăugate: {items_added} | "
                f"Omise (duplicate): {items_skipped} | "
                f"Total: {len(existing_data)}"
            )

        except Exception as e:
            logging.getLogger("api_handlers").error(
                f"❌ Eroare la append în Redis pentru {key_name}: {e}"
            )
            # În caz de eroare gravă, salvează datele noi prin înlocuire
            self.save_to_session_data(key_name, new_data)

    def _extract_dashboard_params(self, data):
        """Extrage și validează parametrii pentru dashboard complet"""
        view_name = data.get("view", "viewBaza_2025")
        if view_name is None:
            return {"error": "Lipsește parametrul 'view'."}

        return {
            "view_name": view_name,
            "filtru": data.get("filtru", None),
            "sort_clause": data.get("sort", None),
            "max_records": data.get("maxRecords", "200"),
            "id_cautat": data.get("idCautat", 0),
        }

    def _extract_refresh_params(self, data):
        """Extrage parametrii pentru refresh rapid (mai puțini)"""
        return {
            "view_name": data.get("view", "viewBaza_2025"),
            "filtru": data.get("filtru", None),
            "sort_clause": data.get("sort", None),
            "max_records": data.get("maxRecords", "200"),
            "id_cautat": data.get("idCautat", 0),
        }

    def _get_sel_tab_from_view(self, view_name):
        """Determină SelTab din numele view-ului"""
        clean_name = view_name.lower()
        if clean_name.startswith("viewbaza"):
            return "nvB1"
        elif clean_name.startswith("viewdosa"):
            return "nvB2"
        elif clean_name.startswith("viewipot"):
            return "nvB3"
        else:
            logging.getLogger("api_handlers").error(f"Eroare view_name {view_name}!")
            return ""

    def _get_view_from_seltab(self, tab_name, suffix="_2025", for_filter=False):
        """Determină View-ul din numele tab-ului"""
        clean_name = tab_name.lower()
        if clean_name.startswith("nvb1"):
            return "viewBaza" + ("_Filtru" if for_filter else "") + suffix
        elif clean_name.startswith("nvb2"):
            return "viewDosar" + ("_Filtru" if for_filter else "") + suffix
        elif clean_name.startswith("nvb3"):
            return "viewIpotecare" + ("_Filtru" if for_filter else "") + suffix
        else:
            logging.getLogger("api_handlers").error(f"Eroare tab_name {tab_name}!")
            return ""

    def _error_response(self, message, status_code):
        """Creează un răspuns de eroare standardizat"""
        return make_response(
            jsonify({"success": False, "message": message}), status_code
        )

    def _success_response(self, data, message="Success"):
        """Creează un răspuns de succes standardizat"""
        response = {"success": True, "message": message}
        if isinstance(data, dict):
            response.update(data)
        else:
            response["data"] = data
        return make_response(jsonify(response), 200)

    def _sanitize_session_keys(self, data):
        """
        Curăță cheile din dicționar pentru a elimina ghilimelele duble
        și convertește cheile numerice înapoi la int
        Args:
            data: Datele din sesiune (dict, list, sau alte tipuri)
        Returns:
            Date curate
        """
        if data is None:
            return {}

        if isinstance(data, dict):
            clean_data = {}
            for key, value in data.items():
                # Curăță cheia - elimină ghilimelele duble dacă există
                if isinstance(key, str):
                    clean_key = key.strip("'\"")
                    # Verifică dacă cheia curățată este numerică și o convertește
                    if clean_key.isdigit():
                        clean_key = int(clean_key)
                else:
                    clean_key = key

                # Procesează valoarea recursiv
                if isinstance(value, dict):
                    clean_data[clean_key] = self._sanitize_session_keys(value)
                elif isinstance(value, list):
                    clean_data[clean_key] = [
                        (
                            self._sanitize_session_keys(item)
                            if isinstance(item, dict)
                            else item
                        )
                        for item in value
                    ]
                else:
                    clean_data[clean_key] = value

            return clean_data

        elif isinstance(data, list):
            return [
                self._sanitize_session_keys(item) if isinstance(item, dict) else item
                for item in data
            ]

        else:
            # Pentru orice alt tip de date, returnează as-is
            return data

    def _prepare_session_data(self, data):
        """
        Pregătește datele pentru salvare în sesiune - previne double-quoting

        Args:
            data: Datele care urmează să fie salvate

        Returns:
            Date curate pentru sesiune
        """
        if data is None:
            return None

        if isinstance(data, dict):
            clean_data = {}
            for key, value in data.items():
                # Convertește cheia la string curat
                if isinstance(key, str):
                    clean_key = key.strip("'\"")
                else:
                    clean_key = str(key)

                # Procesează valoarea recursiv
                if isinstance(value, dict):
                    clean_data[clean_key] = self._prepare_session_data(value)
                elif isinstance(value, list):
                    clean_data[clean_key] = [
                        (
                            self._prepare_session_data(item)
                            if isinstance(item, dict)
                            else item
                        )
                        for item in value
                    ]
                else:
                    clean_data[clean_key] = value

            return clean_data

        elif isinstance(data, list):
            return [
                self._prepare_session_data(item) if isinstance(item, dict) else item
                for item in data
            ]

        else:
            # Pentru orice alt tip de date, returnează as-is
            return data
