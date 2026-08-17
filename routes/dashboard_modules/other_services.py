# route: /dashboard_modules/other_services.py
from multiprocessing.dummy import connection
from modules.db import get_service_conn
import logging
import mysql.connector


class OtherServices:
    def __init__(self):
        self.cache = {}
        self.logger = logging.getLogger(__name__)

    def get_service_conn_dict(self):
        """Returnează conexiune cu cursor dictionary"""
        import mysql.connector

        try:
            connection = get_service_conn()
            # Configurează cursorul să returneze dictionaries
            cursor = connection.cursor(dictionary=True)
            return connection, cursor
        except Exception as e:
            self.logger.error(f"Eroare la obținerea conexiunii DB: {e}")
            raise

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

    def load_judete(self):
        """Încarcă lista județelor din baza de date"""
        connection = None
        cursor = None

        try:
            connection, cursor = self.get_service_conn_dict()
            cursor.execute("SELECT * FROM SVN_00.Judete")
            results = cursor.fetchall()

            self.logger.info(f"Județe încărcate cu succes: {len(results)} înregistrări")
            return results

        except mysql.connector.Error as db_error:
            self.logger.error(f"Eroare MySQL la încărcarea județelor: {db_error}")
            return []
        except Exception as e:
            self.logger.error(f"Eroare neașteptată la încărcarea județelor: {e}")
            return []
        finally:
            # Închidere conexiuni în ordine inversă
            if cursor:
                try:
                    cursor.close()
                except Exception as e:
                    self.logger.error(f"Eroare la închiderea cursor-ului: {e}")
            if connection:
                try:
                    connection.close()
                except Exception as e:
                    self.logger.error(f"Eroare la închiderea conexiunii: {e}")

    def load_surse_agenti(self, department):
        """Încarcă lista surselor agenților din baza de date"""
        connection = None
        cursor = None

        try:
            # Validare parametru
            if not department:
                raise ValueError("Parametrul 'department' este obligatoriu")

            connection, cursor = self.get_service_conn_dict()
            query = f"SELECT * FROM {department}.viewSurseAgenti"
            cursor.execute(query)
            results = cursor.fetchall()

            self.logger.info(
                f"Surse agenți încărcate pentru {department}: {len(results)} înregistrări"
            )
            return results

        except mysql.connector.Error as db_error:
            self.logger.error(
                f"Eroare MySQL la încărcarea surselor agenți pentru {department}: {db_error}"
            )
            return []
        except ValueError as ve:
            self.logger.error(f"Eroare validare parametri: {ve}")
            return []
        except Exception as e:
            self.logger.error(
                f"Eroare neașteptată la încărcarea surselor agenți pentru {department}: {e}"
            )
            return []
        finally:
            # Închidere conexiuni în ordine inversă
            if cursor:
                try:
                    cursor.close()
                except Exception as e:
                    self.logger.error(f"Eroare la închiderea cursor-ului: {e}")
            if connection:
                try:
                    connection.close()
                except Exception as e:
                    self.logger.error(f"Eroare la închiderea conexiunii: {e}")

    def load_feedback(self, department, IdBaza):
        """Încarcă feedback-ul din baza pentru Id-ul selectat din tabel"""
        connection = None
        cursor = None

        try:
            connection, cursor = self.get_service_conn_dict()
            cursor.execute(
                f"SELECT * FROM {department}.view_Baza_FeedBack_PYTHON WHERE IdBaza={IdBaza}"
            )
            results = cursor.fetchall()

            self.logger.info(
                f"Feedback încărcate cu succes pentru IdBaza {IdBaza}: {len(results)} înregistrări"
            )
            return results

        except mysql.connector.Error as db_error:
            self.logger.error(f"Eroare MySQL la încărcarea județelor: {db_error}")
            return []
        except Exception as e:
            self.logger.error(f"Eroare neașteptată la încărcarea județelor: {e}")
            return []
        finally:
            # Închidere conexiuni în ordine inversă
            if cursor:
                try:
                    cursor.close()
                except Exception as e:
                    self.logger.error(f"Eroare la închiderea cursor-ului: {e}")
            if connection:
                try:
                    connection.close()
                except Exception as e:
                    self.logger.error(f"Eroare la închiderea conexiunii: {e}")

    def load_consultanti(self, IdConsultant):
        """Încarcă lista consultantilor din baza de date"""
        connection = None
        cursor = None

        try:
            connection, cursor = self.get_service_conn_dict()
            query = f"""
                    SELECT DISTINCT 
                        c.IdConsultant,
                        c.IdParinte,
                        c.IdNivel,
                        c.NumeConsultant,
                        c.CNP,
                        c.Adresa,
                        c.Ascuns,
                        c.Functie,
                        c.cMail,
                        c.cTelefon,
                        c.CodJudet,
                        c.CodOras,
                        c.Plecat,
                        c.Sistem
                    FROM Consultanti c
                    WHERE 
                        c.Ascuns = 0 
                        AND c.Plecat = 0
                        AND (
                            -- Dacă nivelul >= 40, ia toți consultanții
                            (SELECT IdNivel FROM SVN_00.Consultanti WHERE IdConsultant = {IdConsultant}) >= 40
                            OR
                            -- Dacă nivelul < 40, ia doar subordonații (inclusiv pe sine)
                            (
                                (SELECT IdNivel FROM SVN_00.Consultanti WHERE IdConsultant = {IdConsultant}) < 40
                                AND 
                                (
                                    c.IdConsultant = {IdConsultant}  -- Include și pe sine
                                    OR
                                    c.IdConsultant IN (
                                        SELECT IdCopilCopil 
                                        FROM SVN_00.Consultanti_Copii 
                                        WHERE IdCopil = {IdConsultant}
                                    )
                                )
                            )
                        )
                    ORDER BY 
                        c.IdNivel ASC,
                        c.NumeConsultant ASC;
                    """

            cursor.execute(query)
            results = cursor.fetchall()

            self.logger.info(
                f"Consultanti încărcați pentru {IdConsultant}: {len(results)} înregistrări"
            )
            return results

        except mysql.connector.Error as db_error:
            self.logger.error(
                f"Eroare MySQL la încărcarea consultantilor pentru {IdConsultant}: {db_error}"
            )
            return []
        except ValueError as ve:
            self.logger.error(f"Eroare validare parametri: {ve}")
            return []
        except Exception as e:
            self.logger.error(
                f"Eroare neașteptată la încărcarea consultantilor pentru {IdConsultant}: {e}"
            )
            return []
        finally:
            # Închidere conexiuni în ordine inversă
            if cursor:
                try:
                    cursor.close()
                except Exception as e:
                    self.logger.error(f"Eroare la închiderea cursor-ului: {e}")
            if connection:
                try:
                    connection.close()
                except Exception as e:
                    self.logger.error(f"Eroare la închiderea conexiunii: {e}")

    def load_baza_status(self, department):
        """Încarcă lista status-urilor pentru feedback din baza de date"""
        connection = None
        cursor = None

        try:
            connection, cursor = self.get_service_conn_dict()

            query = f"""
                SELECT 
                    IdStatus,
                    FelStatus,
                    TipStatus,
                    CONCAT('#', 
                        LPAD(HEX(
                            ((COALESCE(BackColor, 0xFFFFFF) & 0xFF) << 16) |
                            (COALESCE(BackColor, 0xFFFFFF) & 0xFF00) |
                            ((COALESCE(BackColor, 0xFFFFFF) & 0xFF0000) >> 16)
                        ), 6, '0')
                    ) AS BackColor,
                    Ascuns,
                    IDSG
                FROM {department}.Baza_Status 
                FORCE INDEX (FelStatus)
                WHERE Ascuns = 0
                ORDER BY FelStatus
            """

            cursor.execute(query)
            results = cursor.fetchall()

            self.logger.info(
                f"Status-uri încărcate cu succes: {len(results)} înregistrări"
            )
            return results

        except mysql.connector.Error as db_error:
            self.logger.error(f"Eroare MySQL la încărcarea status-urilor: {db_error}")
            return []
        except Exception as e:
            self.logger.error(f"Eroare neașteptată la încărcarea status-urilor: {e}")
            return []
        finally:
            if cursor:
                try:
                    cursor.close()
                except Exception as e:
                    self.logger.error(f"Eroare la închiderea cursor-ului: {e}")
            if connection:
                try:
                    connection.close()
                except Exception as e:
                    self.logger.error(f"Eroare la închiderea conexiunii: {e}")

    def verifica_telefon(self, department, telefon, IdConsultant):
        """
        Verifică dacă un număr de telefon este valid pentru utilizare
        Apelează procClient_ADD_2025 pentru a găsi istoric client

        Args:
            department: Departamentul (ex: SVN_IM)
            telefon: Numărul de telefon de verificat
            IdConsultant: ID-ul consultantului curent (exclude din rezultate)

        Returns:
            dict: {
                "success": bool,
                "telefon": str,
                "util": "DA"/"NU",
                "count_baza": int,
                "count_dosar": int,
                "total_records": int,
                "records": [...]
            }
        """
        connection = None
        cursor = None
        results = []

        try:
            # Validare parametri
            if not telefon or not telefon.strip():
                return {
                    "success": False,
                    "message": "Numărul de telefon este obligatoriu",
                    "telefon": telefon,
                    "util": "DA",
                    "count_baza": 0,
                    "count_dosar": 0,
                    "total_records": 0,
                    "records": [],
                }

            if not IdConsultant:
                raise ValueError("IdConsultant este obligatoriu")

            # Curăță numărul de telefon
            telefon_curatat = telefon.strip()

            connection, cursor = self.get_service_conn_dict()

            # Apelează procedura
            call_query = f"CALL {department}.procClient_ADD_2025_PYTHON(%s, %s)"

            self.logger.info(
                f"🔍 Verificare telefon: {telefon_curatat} pentru IdConsultant={IdConsultant}"
            )

            cursor.execute(call_query, (telefon_curatat, IdConsultant))
            results = cursor.fetchall()

            # Consumă toate seturile de rezultate (dacă există - pare ca trebuie pe proceduri?)
            while cursor.nextset():
                pass

            # Procesează rezultatele
            if not results or len(results) == 0:
                # Telefon UTIL - nu există în baza de date la alți consultanți
                self.logger.info(
                    f"✅ Telefon {telefon_curatat} este UTIL (fără istoric)"
                )
                return {
                    "success": True,
                    "telefon": telefon_curatat,
                    "util": "DA",
                    "count_baza": 0,
                    "count_dosar": 0,
                    "total_records": 0,
                    "records": [],
                    "message": "Telefon valid - nu există în sistem la alți consultanți",
                }

            # Defineste variabilele pentru counts
            count_baza = 0
            count_dosar = 0
            util = ""
            message = ""

            # Extrage datele din primul rând pentru counts
            first_record = results[0]
            count_baza = int(first_record.get("CBaza", 0))
            count_dosar = int(first_record.get("CDosar", 0))
            util = first_record.get("Util", "NU")

            # Procesează toate înregistrările
            records = []
            for row in results:
                count_baza += int(row.get("CBaza", 0))
                count_dosar += int(row.get("CDosar", 0))
                # Dacă oricare are Util="NU", atunci totul e "NU"
                if row.get("Util", "NU") == "NU":
                    util = "NU"

                record = {
                    "IdClient": row.get("IdClient"),
                    "IdBaza": row.get("Idbaza"),
                    "IdDosar": row.get("IdDosar"),
                    "IdConsultant": row.get("IdConsultant"),
                    "IdSursa": row.get("IdSursa"),
                    "IDAgent": row.get("IDAgent"),
                    "DataPrimire": (
                        row.get("DataPrimire").strftime("%d.%m.%Y %H:%M:%S")
                        if row.get("DataPrimire")
                        else None
                    ),
                    "Consultant": row.get("Consultant"),
                    "TelefonConsultant": row.get("TelefonConsultant"),
                    "Sursa": row.get("Sursa"),
                    "Agent": row.get("Agent"),
                    "NumeClient": row.get("NumeClient"),
                    "CNPClient": row.get("CNPClient"),
                    "EmailP": row.get("EmailP"),
                    "IdJudet": row.get("IdJudet"),
                    "Judet": row.get("Judet"),
                    "Tara": row.get("Tara"),
                    "RO": row.get("RO"),
                    "DataNastere": (
                        row.get("DataNastere").strftime("%d.%m.%Y")
                        if row.get("DataNastere")
                        else None
                    ),
                    "IDSG": row.get("IDSG"),
                    "BackColor": row.get("BkColor"),
                    "StatusFinal": row.get("StatusFinal"),
                    "Util": row.get("Util", "NU"),
                    "CBaza": int(row.get("CBaza", 0)),
                    "CDosar": int(row.get("CDosar", 0)),
                }
                records.append(record)

            # Construiește mesajul
            if util == "NU":
                message = f"⚠️ Telefon INVALID: găsite {count_baza} baze și {count_dosar} dosare cu probleme la alți consultanți"
                self.logger.warning(f"❌ {message}")
            else:
                message = f"✅ Telefon VALID: găsite {len(results)} înregistrări fără probleme la alți consultanți"
                self.logger.info(message)

            return {
                "success": True,
                "telefon": telefon_curatat,
                "util": util,
                "count_baza": count_baza,
                "count_dosar": count_dosar,
                "total_records": len(results),
                "records": records,
                "message": message,
            }

        except mysql.connector.Error as db_error:
            self.logger.error(
                f"Eroare MySQL la verificarea telefonului {telefon}: {db_error}"
            )
            return []
        except ValueError as ve:
            self.logger.error(f"Eroare validare parametri: {ve}")
            return []
        except Exception as e:
            self.logger.error(
                f"Eroare neașteptată la la verificarea telefonului {telefon}: {e}"
            )
            return []
        finally:
            # Închidere conexiuni în ordine inversă
            if cursor:
                try:
                    cursor.close()
                except Exception as e:
                    self.logger.error(f"Eroare la închiderea cursor-ului: {e}")
            if connection:
                try:
                    connection.close()
                except Exception as e:
                    self.logger.error(f"Eroare la închiderea conexiunii: {e}")

    def get_user_rights(self, IdConsultant):
        """Obține drepturile utilizatorului pentru department"""
        try:
            with self._get_db_connection() as (conn, cursor):
                sql = f"""
                    SELECT
                        SVN_00.Drepturi.IdDrept, 
                        SVN_00.Drepturi.Drept, 
                        SVN_00.Drepturi.ValoareImplicita, 
                        SVN_00.Consultanti_Drepturi.Valoare
                    FROM
                        SVN_00.Drepturi
                        INNER JOIN
                        SVN_00.Consultanti_Drepturi
                        ON 
                            SVN_00.Drepturi.IdDrept = SVN_00.Consultanti_Drepturi.IdDrept
                    WHERE
                        SVN_00.Consultanti_Drepturi.IdConsultant = %s
                """
                cursor.execute(sql, (IdConsultant,))
                rows = cursor.fetchall()

                return [
                    {
                        "id_drept": row["IdDrept"],
                        "drept": row["Drept"],
                        "valoare_implicita": row["ValoareImplicita"],
                        "valoare": row["Valoare"],
                    }
                    for row in rows
                ]

        except Exception as e:
            self.logger.error(f"❌ Eroare în get_user_rights: {e}")
            return []
