# ========== routes/dashboard_modules/row_services.py ==========
"""
🗄️ ROW SERVICES MODULE
Execuție proceduri SQL și procesare date
"""

from modules.db import get_service_conn
from datetime import datetime
import logging


# ========== ENHANCED VERSION WITH CONTEXT MANAGER ==========
class RowServices:
    """Version with context manager for even safer connection handling"""

    def __init__(self):
        self.logger = logging.getLogger("row_services")

    def _get_db_connection(self):
        """Context manager pentru conexiuni DB"""

        class DBConnection:
            def __init__(self, logger):
                self.logger = logger

            def __enter__(self):
                try:
                    self.conn = get_service_conn()
                    self.cursor = self.conn.cursor(dictionary=True)
                    return self.conn, self.cursor
                except Exception as e:
                    self.logger.error(f"Failed to get DB connection: {e}")
                    raise

            def __exit__(self, exc_type, exc_val, exc_tb):
                if hasattr(self, "cursor") and self.cursor:
                    try:
                        # Consume any remaining result sets
                        try:
                            while self.cursor.nextset():
                                pass
                        except:
                            pass
                        self.cursor.close()
                    except Exception as e:
                        self.logger.error(f"Error closing cursor: {e}")

                if hasattr(self, "conn") and self.conn:
                    try:
                        self.conn.close()
                    except Exception as e:
                        self.logger.error(f"Error closing connection: {e}")

                # Log any exceptions that occurred
                if exc_type:
                    self.logger.error(
                        f"Exception in DB operation: {exc_type.__name__}: {exc_val}"
                    )

        return DBConnection(self.logger)

    def execute_main_procedure_safe(
        self,
        department,
        IdConsultant,
        IdNivel,
        view_name,
        filtru,
        sort_clause,
        id_cautat,
        max_records=200,
    ):
        """Safe version using context manager - returns dict for compatibility"""
        try:
            with self._get_db_connection() as (conn, cursor):
                # Validate sort clause
                if isinstance(sort_clause, dict):
                    column = sort_clause.get("column", "")
                    direction = sort_clause.get("direction", "")
                    if column and direction:
                        sort_final = f"{column} {direction.upper()}"
                    else:
                        sort_final = "IdBaza DESC"
                elif isinstance(sort_clause, str) and sort_clause.strip():
                    sort_final = sort_clause
                else:
                    sort_final = "IdBaza DESC"

                call_query = f"""
                    CALL {department}.procMain_Filter_2025({IdConsultant},{IdNivel},"{view_name}","{filtru}","{sort_final}",{max_records},{id_cautat})
                """

                self.logger.info(f"🔧 Execut SQL: {call_query}")
                cursor.execute(call_query)

                # Get all columns returned by procedure
                all_columns = (
                    [desc[0] for desc in cursor.description]
                    if cursor.description
                    else []
                )
                rows = cursor.fetchall()

                self.logger.info(
                    f"✅ Date brute: {len(rows)} rânduri, {len(all_columns)} coloane SQL"
                )

                # Return as dict for compatibility with api_handlers
                return {"rows": rows, "columns": all_columns}

        except Exception as e:
            self.logger.error(f"❌ Eroare în execute_main_procedure_safe: {e}")
            return {"rows": [], "columns": []}

    def execute_main_procedure_raw(
        self,
        department,
        IdConsultant,
        IdNivel,
        view_name,
        filtru,
        sort_clause,
        id_cautat,
        max_records=2000,
    ):
        """Raw version - just calls the safe version"""
        return self.execute_main_procedure_safe(
            department,
            IdConsultant,
            IdNivel,
            view_name,
            filtru,
            sort_clause,
            id_cautat,
            max_records,
        )

    def process_data_rows(self, rows, allowed_columns, selTab):
        """Procesează rândurile cu allowed_columns ca listă"""
        try:
            filtered_data = []
            primary_key = None

            # Stabileste coloana principala (PK) in functie se selTab
            if selTab == "nvB1":
                primary_key = "IdBaza"
            elif selTab == "nvB2":
                primary_key = "IdDosar"
            elif selTab == "nvB3":
                primary_key = "IdIpotecare"

            for row in rows:
                filtered_row = {}
                filtered_row["Id"] = row.get(primary_key, None)
                # ✅ SCHIMBAT: Iterează prin lista în loc de dictionary
                for column_config in allowed_columns:
                    id_coloana = column_config["id"]
                    field_name = column_config["field"]

                    if field_name in row:
                        value = row[field_name]
                        display_value = self.format_cell_value(value, column_config)

                        # Stilul implicit
                        cell_style = {
                            "value": display_value,
                            "back_color": "#FFFFFF",
                            "fore_color": "#000000",
                            "font_bold": False,
                            "font_underline": False,
                            "font_italic": False,
                        }

                        # ✅ conditional_formatting e direct în column_config
                        conditional_formatting = column_config.get(
                            "conditional_formatting", []
                        )

                        if conditional_formatting:
                            for rule in conditional_formatting:
                                rule_field = rule.get("nume_coloana_fc")

                                if rule_field and rule_field in row:
                                    check_value = row[rule_field]

                                    if (
                                        check_value is not None
                                        and self._check_condition(
                                            check_value,
                                            rule["semn"],
                                            rule["valoare_js"],
                                        )
                                    ):
                                        cell_style.update(
                                            {
                                                "back_color": rule["back_color"],
                                                "fore_color": rule["fore_color"],
                                                "font_bold": rule["font_bold"],
                                                "font_underline": rule[
                                                    "font_underline"
                                                ],
                                                "font_italic": rule["font_italic"],
                                            }
                                        )
                                        break

                        filtered_row[id_coloana] = cell_style

                filtered_data.append(filtered_row)
            return filtered_data

        except Exception as e:
            self.logger.error(f"❌ Eroare în process_data_rows: {e}")
            return []

    def format_cell_value(self, value, config):
        """Formatează valoarea unei celule bazat pe configurație"""
        try:
            if value is None:
                return ""

            formatare = config.get("format")

            if formatare == "Long Time":
                if isinstance(value, datetime):
                    return value.strftime("%d.%m.%Y %H:%M:%S")
                else:
                    return str(value)
            elif formatare == "Short Date":
                if isinstance(value, datetime):
                    return value.strftime("%d/%m/%Y")
                else:
                    return str(value)
            elif formatare == "Percent":
                if isinstance(value, (int, float)):
                    return f"{value * 100:.2f}%"
                else:
                    return str(value)
            elif formatare == "Standard":
                if isinstance(value, (int, float)):
                    return f"{int(value):,}".replace(",", ".")
                else:
                    return str(value)
            elif formatare == "@@@@ @@@ @@@":
                str_value = str(value)
                if len(str_value) == 10 and str_value.startswith("0"):
                    return f"{str_value[:4]} {str_value[4:7]} {str_value[7:]}"
                else:
                    return str_value
            else:
                return str(value)

        except Exception as e:
            self.logger.error(f"❌ Eroare în format_cell_value: {e}")
            return str(value) if value is not None else ""

    def execute_count_procedure(
        self, department, IdConsultant, IdNivel, view_name, filtru
    ):
        """Safe version of count procedure"""
        try:
            with self._get_db_connection() as (conn, cursor):
                # Mapare view -> procedură
                proc_map = {
                    "viewBaza_2025": "procCount_Baza_2025",
                    "viewDosa_2025": "procCount_Dosar_2025",
                    "viewIpotecare_2025": "procCount_Ipotecare_2025",
                }

                cursor = conn.cursor(dictionary=True)
                proc_name = proc_map.get(view_name, "procCount_Baza_2025")

                call_query = f"""
                    CALL {department}.{proc_name}({IdConsultant},{IdNivel},"{filtru}")
                """

                self.logger.info(f"{call_query}")

                cursor.execute(call_query)
                row = cursor.fetchone()

                if row and len(row) >= 4:
                    return {
                        # Test if elements are not none
                        "red": (
                            int(row.get("bDR0", 0))
                            if row.get("bDR0") is not None
                            else 0
                        ),
                        "green": (
                            int(row.get("bDR1", 0))
                            if row.get("bDR1") is not None
                            else 0
                        ),
                        "yellow": (
                            int(row.get("bDR2", 0))
                            if row.get("bDR2") is not None
                            else 0
                        ),
                        "total": (
                            int(row.get("TotalRows", 0))
                            if row.get("TotalRows") is not None
                            else 0
                        ),
                    }
                else:
                    return {"red": 0, "green": 0, "yellow": 0}

        except Exception as e:
            self.logger.error(f"❌ Eroare în execute_count_procedure: {e}")
            return {"red": 0, "green": 0, "yellow": 0}

    def _check_condition(self, value, operator, compare_value):
        """Verifică condiția pentru formatare"""
        try:
            # Determină tipul și convertește
            try:
                # Încearcă conversie numerică
                val = float(value) if value is not None else 0
                comp_val = float(compare_value)
                is_numeric = True
            except (ValueError, TypeError):
                # Folosește ca string
                val = str(value).strip() if value is not None else ""
                comp_val = str(compare_value).strip()
                is_numeric = False

            # Aplică operatorul
            if operator == "=":
                return val == comp_val
            elif operator == "!=":
                return val != comp_val
            elif operator in [">", "<", ">=", "<="]:
                # Comparații numerice doar pentru numere
                if not is_numeric:
                    return False
                if operator == ">":
                    if isinstance(val, (int, float)) and isinstance(
                        comp_val, (int, float)
                    ):
                        return val > comp_val
                    else:
                        return False
                elif operator == "<":
                    if isinstance(val, (int, float)) and isinstance(
                        comp_val, (int, float)
                    ):
                        return val < comp_val
                    else:
                        return False
                elif operator == ">=":
                    if isinstance(val, (int, float)) and isinstance(
                        comp_val, (int, float)
                    ):
                        return val >= comp_val
                    else:
                        return False
                elif operator == "<=":
                    if isinstance(val, (int, float)) and isinstance(
                        comp_val, (int, float)
                    ):
                        return val <= comp_val
                    else:
                        return False
            elif operator == "IN":
                # Pentru IN, compare_value poate fi listă separată prin virgulă
                values_list = [v.strip() for v in str(compare_value).split(",")]
                return str(val) in values_list
            elif operator == "LIKE":
                # Simplu pattern matching
                pattern = str(comp_val).replace("%", ".*")
                import re

                return re.match(pattern, str(val), re.IGNORECASE) is not None
            else:
                return False

        except Exception as e:
            self.logger.error(f"⚠️ Eroare în verificare condiție: {e}")
            return False

    def convert_to_simple_format(self, rows):
        """Convertește datele brute în format simplu pentru frontend"""
        simple_data = []
        for row in rows:
            simple_row = []
            for value in row:
                if value is None:
                    simple_row.append("")
                elif isinstance(value, datetime):
                    simple_row.append(value.strftime("%d.%m.%Y %H:%M:%S"))
                else:
                    simple_row.append(str(value))
            simple_data.append(simple_row)
        return simple_data


# ========== CONNECTION MONITORING UTILITY ==========
def monitor_connection_usage():
    """Utility function to monitor connection pool status"""
    try:
        # Test basic connection
        with get_service_conn() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT 1")
            result = cursor.fetchone()
            cursor.close()

        logging.getLogger("row_services").info("✅ Connection pool test successful")
        return True

    except Exception as e:
        logging.getLogger("row_services").error(f"❌ Connection pool test failed: {e}")
        return False
