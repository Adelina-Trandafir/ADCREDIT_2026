# ========== routes/dashboard_modules/column_service.py ==========
"""
📋 COLUMN SERVICE MODULE
Configurare și metadata coloane
"""

from modules.db import get_service_conn
import logging


class ColumnServices:

    def __init__(self):
        self.cache = {}

    def get_service_conn_dict(self):
        """Returnează conexiune cu cursor dictionary"""
        import mysql.connector

        connection = get_service_conn()
        # Configurează cursorul să returneze dictionaries
        cursor = connection.cursor(dictionary=True)
        return connection, cursor

    def load_conditional_formatting_rules(self, department, sel_tab):
        """Încarcă regulile de formatare condiționată"""

        admin_conn, cursor = self.get_service_conn_dict()

        color_query = f"""
        SELECT 
            CAST(cf.IdColoana AS VARCHAR(3)) as IdColoana, 
            CAST(cf.IdColoanaFC AS VARCHAR(3)) as IdColoanaFC, 
            cf.Semn, 
            cf.ValoareJS,
            -- Conversie BGR -> RGB pentru BackColor
            CONCAT('#', 
                LPAD(HEX(
                    ((COALESCE(cf.BackColor, 0xFFFFFF) & 0xFF) << 16) |
                    (COALESCE(cf.BackColor, 0xFFFFFF) & 0xFF00) |
                    ((COALESCE(cf.BackColor, 0xFFFFFF) & 0xFF0000) >> 16)
                ), 6, '0')
            ) AS BackColor,
            -- Conversie BGR -> RGB pentru ForeColor  
            CONCAT('#',
                LPAD(HEX(
                    ((COALESCE(cf.ForeColor, 0x000000) & 0xFF) << 16) |
                    (COALESCE(cf.ForeColor, 0x000000) & 0xFF00) |
                    ((COALESCE(cf.ForeColor, 0x000000) & 0xFF0000) >> 16)
                ), 6, '0')
            ) AS ForeColor,
            cf.FontBold, 
            cf.FontUnderline, 
            cf.FontItalic,
            cf.NumeColoana,
            ci.NumeColoana as NumeColoanaFC
        FROM 
            {department}.Coloane_FC cf INNER JOIN {department}.Coloane_Implicite ci ON cf.IdColoanaFC=ci.IdColoana
        WHERE 
            cf.IdColoanaFC IS NOT NULL 
            AND cf.ValoareJS IS NOT NULL 
            AND cf.SelTab = %s
            AND cf.Activ = 1
        ORDER BY 
            cf.IdColoana, cf.IdColoanaFC, CAST(cf.ValoareJS AS SIGNED)
        """

        cursor.execute(color_query, (sel_tab,))
        color_rules_raw = cursor.fetchall()
        cursor.close()
        admin_conn.close()

        # Organizează regulile per IdColoana
        color_rules = {}
        for rule in color_rules_raw:
            id_coloana = str(rule["IdColoana"])
            if id_coloana not in color_rules:
                color_rules[id_coloana] = []
            color_rules[id_coloana].append(
                {
                    "id_coloana_fc": str(rule["IdColoanaFC"]),
                    "semn": rule["Semn"],
                    "valoare_js": rule["ValoareJS"],
                    "back_color": rule["BackColor"],
                    "fore_color": rule["ForeColor"],
                    "font_bold": rule["FontBold"],
                    "font_underline": rule["FontUnderline"],
                    "font_italic": rule["FontItalic"],
                    "nume_coloana": rule["NumeColoana"],
                    "nume_coloana_fc": rule["NumeColoanaFC"],
                }
            )

        # self.cache[cache_key] = color_rules
        return color_rules

    def load_complete_configuration(self, department, IdConsultant, sel_tab):
        """Încarcă configurația completă a coloanelor"""
        cache_key = f"{department}_{IdConsultant}_{sel_tab}"

        if cache_key in self.cache:
            return self.cache[cache_key]

        columns_FC = self.load_conditional_formatting_rules(department, sel_tab)

        (
            allowed_columns,
            all_columns,
            columns_order,
        ) = self.load_columns_configuration(
            department, IdConsultant, sel_tab, columns_FC
        )

        config = {
            "all_columns": all_columns,
            "allowed_columns": allowed_columns,
            "columns_order": columns_order,
            "columns_FC": columns_FC,
        }

        self.cache[cache_key] = config
        return config

    def load_columns_configuration(self, department, IdConsultant, sel_tab, columns_FC):
        """Încarcă configurația coloanelor cu field names direct"""

        admin_conn, cursor = self.get_service_conn_dict()

        columns_config_query = f"""
        SELECT 
            ci.IdColoana,
            ci.NumeColoana,
            cc.Afisare,
            cc.Pozitie,
            ci.PozitieInitiala,
            COALESCE(CAST((cc.Marime / 15) as int), -1) as Marime,
            COALESCE(CAST((ci.MarimeInitiala / 15) as int), -1) as MarimeInitiala,						
            cc.Aliniere,
            cc.Formatare,
            cc.Special,
            ci.ColoanaPK,
            ci.TipCamp,
            ci.JS_ReadOnlyCbx,
            ci.NumeTabel,
            cc.Ascuns,
            ci.AscunsInFiltru
        FROM 
            {department}.Consultanti_Coloane cc
            INNER JOIN {department}.Coloane_Implicite ci 
                ON cc.IdColoana = ci.IdColoana
        WHERE 
            cc.IdConsultant = %s 
            AND cc.SelTab = %s
        ORDER BY 
            cc.Pozitie ASC
        """

        cursor.execute(columns_config_query, (IdConsultant, sel_tab))
        columns_raw = cursor.fetchall()

        cursor.close()
        admin_conn.close()

        # Procesare cu field names directe
        allowed_columns = []
        all_columns = []
        columns_order = []

        # Procesează coloanele vizibile cu field names
        for row in columns_raw:
            id = str(row["IdColoana"])

            column_config = {
                "id": id,
                "field": row["NumeColoana"],
                "header": row["Afisare"] or row["NumeColoana"],
                "width": int(row["Marime"]) or 100,
                "align": (
                    ["", "left", "center", "right"][row["Aliniere"]]
                    if row["Aliniere"] < 4
                    else "left"
                ),
                "format": row["Formatare"],
                "conditional_formatting": columns_FC.get(id, []),
                "special": row["Special"],
                "PK": row["ColoanaPK"],
                "TipCamp": row["TipCamp"],
                "js_readonly": row["JS_ReadOnlyCbx"],
                "NumeTabel": row["NumeTabel"],
                "Ascuns": row["Ascuns"],  # Default la 1, adica ascuns
                "AscunsInFiltru": row["AscunsInFiltru"],  # Default la 1, adica ascuns
                "pozitie": row["Pozitie"],
            }

            all_columns.append(column_config)

            if row["Ascuns"] == 0:
                allowed_columns.append(column_config)

            columns_order.append(id)

        return (
            allowed_columns,
            all_columns,
            columns_order,
        )

    def get_unique_column_values(
        self,
        department,
        column_field,
        PK,
        filtru,
        view_name,
        otherFilters,
        BaseTable=None,
    ):
        """Returnează valorile unice pentru o coloană"""

        # Construiește query-ul de bază
        if BaseTable:
            # Cu INNER JOIN când avem BaseTable
            query = f"""
                SELECT DISTINCT {department}.{view_name}.{PK} as ID, {department}.{view_name}.{column_field} as value
                FROM {department}.{view_name}
                INNER JOIN (SELECT {department}.{BaseTable}.{PK}, Ascuns FROM {department}.{BaseTable}) as BaseTable USING ({PK})
            """
        else:
            # Fără JOIN când nu avem BaseTable
            query = f"""
                SELECT DISTINCT {department}.{view_name}.{PK} as ID, {department}.{view_name}.{column_field} as value
                FROM {department}.{view_name}
            """

        # Adaugă WHERE doar dacă există filtre
        where_conditions = []

        # Adaugă condiția pentru BaseTable dacă există
        if BaseTable:
            where_conditions.append("BaseTable.Ascuns=0")

        # Adaugă filtrele existente
        if filtru and filtru.strip():
            where_conditions.append(filtru)

        if otherFilters and otherFilters.strip():
            where_conditions.append(otherFilters)

        # Construiește clauza WHERE
        if where_conditions:
            query += f" WHERE {' AND '.join(where_conditions)}"

        # Sortarea se face în MariaDB pentru performanță
        query += f" ORDER BY {department}.{view_name}.{column_field} LIMIT 100"

        logging.getLogger("api_handlers").info(query)

        connection = get_service_conn()
        cursor = connection.cursor()
        cursor.execute(query)

        values = [(r[0], r[1]) for r in cursor.fetchall()]

        cursor.close()
        connection.close()

        return values

    # aici se formeaza rezultatul pentru JS. Adauga si aici orice coloana descarcata in load_complete_configuration
    def prepare_columns_metadata(self, allowed_columns, columns_order, columns_FC):
        """Pregătește metadatele coloanelor pentru frontend"""
        columns_metadata = []
        for id_coloana in columns_order:
            if id_coloana in allowed_columns:
                config = allowed_columns[id_coloana]
                columns_metadata.append(
                    {
                        "id": str(id_coloana),
                        "field": config["nume_coloana"],
                        "header": config["afisare"],
                        "width": config["marime"],
                        "align": (
                            ["", "left", "center", "right"][config["aliniere"]]
                            if config["aliniere"] < 4
                            else "left"
                        ),
                        "format": config["formatare"],
                        "conditional_formatting": columns_FC.get(id_coloana, []),
                        "special": config["special"],
                        "PK": config["PK"],
                        "js_readonly": config.get("js_readonly", False),
                        "TipCamp": config.get("TipCamp"),
                        "NumeTabel": config.get("NumeTabel"),
                        "Ascuns": config.get("Ascuns", 1),  # Default la 1 - ascuns
                        "pozitie": config["pozitie"],
                    }
                )

        return columns_metadata

    def clear_cache(self):
        """Șterge cache-ul coloanelor"""
        self.cache.clear()
