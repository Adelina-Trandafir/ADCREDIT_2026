# ========== routes/dashboard_modules/session_manager.py ==========
"""
🔐 SESSION MANAGER MODULE
Gestionare sesiuni, autentificare și informații utilizator
Responsabilități:
- Validare și recuperare sesiuni
- Obținere informații utilizator din DB
- Verificare permisiuni și nivele acces
"""

from flask import session
from modules.db import get_service_conn
import logging

# Setup logging
logger = logging.getLogger(__name__)


class SessionManager:
    """Gestionare centralizată a sesiunilor și utilizatorilor"""

    def __init__(self):
        self.current_user = None
        self.current_department = None

    def validate_and_recover_session(self):
        """
        Validează sesiunea și recuperează departmentul dacă lipsește

        Returns:
            tuple: (error_response, status_code) sau (None, None) dacă OK
        """
        # Verifică dacă utilizatorul este logat
        if "user" not in session:
            return {
                "success": False,
                "message": "Sesiune expirată.",
                "redirect": "/login",
            }, 401

        # Fix pentru F5 - recuperează department dacă lipsește
        # if "department" not in session:
        #     email = session["user"]
        #     result = self._recover_department_from_db(email)

        #     if not result:
        #         return {
        #             "success": False,
        #             "message": "Departament invalid.",
        #             "redirect": "/login",
        #         }, 401

        #     session["department"] = result
        #     logger.info(f"🔧 Departament recuperat pentru {email}: {result}")

        # Setează utilizatorul curent în clasă pentru cache
        self.current_user = session["user"]
        self.current_department = session["department"]

        return None, None

    # def _recover_department_from_db(self, email):
    #     """
    #     Recuperează departmentul utilizatorului din baza de date

    #     Args:
    #         email (str): Email-ul utilizatorului

    #     Returns:
    #         str|None: Departamentul sau None dacă nu există
    #     """
    #     temp_conn = None
    #     temp_cursor = None

    #     try:
    #         temp_conn = get_service_conn()
    #         temp_cursor = temp_conn.cursor()

    #         query = "SELECT Departament FROM SVN_00.Consultanti WHERE cMail = %s"
    #         temp_cursor.execute(query, (email,))
    #         result = temp_cursor.fetchone()

    #         return result[0] if result and result[0] else None

    #     except Exception as e:
    #         logger.error(f"❌ Eroare la recuperarea departmentului: {e}")
    #         return None

    #     finally:
    #         # CRITICAL: Always close connections in finally block
    #         if temp_cursor:
    #             try:
    #                 temp_cursor.close()
    #             except Exception as e:
    #                 logger.error(f"Error closing cursor: {e}")

    #         if temp_conn:
    #             try:
    #                 temp_conn.close()
    #             except Exception as e:
    #                 logger.error(f"Error closing connection: {e}")

    def get_user_info(self):
        """
        Returnează informații complete despre utilizatorul curent

        Returns:
            tuple: (email, department, IdConsultant, IdNivel)
        """
        if not self.current_user or not self.current_department:
            # Încearcă să obții din sesiune dacă nu sunt cached
            email = session.get("user")
            department = session.get("department")
        else:
            email = self.current_user
            department = self.current_department

        if not email or not department:
            return None, None, None, None

        admin_conn = None
        cursor = None

        try:
            admin_conn = get_service_conn()
            cursor = admin_conn.cursor()

            query = """
                SELECT IdConsultant, IdNivel 
                FROM SVN_00.Consultanti 
                WHERE cMail = %s AND Ascuns = 0 AND Plecat = 0
            """
            cursor.execute(query, (email,))
            result = cursor.fetchone()

            if not result:
                return None, None, None, None

            IdConsultant = result[0]
            IdNivel = result[1] if result[1] else 1

            return email, department, IdConsultant, IdNivel

        except Exception as e:
            logger.error(f"❌ Eroare la obținerea informațiilor utilizator: {e}")
            return None, None, None, None

        finally:
            # CRITICAL: Always close connections in finally block
            if cursor:
                try:
                    cursor.close()
                except Exception as e:
                    logger.error(f"Error closing cursor: {e}")

            if admin_conn:
                try:
                    admin_conn.close()
                except Exception as e:
                    logger.error(f"Error closing connection: {e}")

    def check_user_permissions(self, required_level=1):
        """
        Verifică dacă utilizatorul are permisiunile necesare

        Args:
            required_level (int): Nivelul minim necesar

        Returns:
            bool: True dacă are permisiuni, False altfel
        """
        _, _, _, IdNivel = self.get_user_info()

        if IdNivel is None:
            return False

        return IdNivel >= required_level

    def get_user_department_info(self):
        """
        Returnează doar email și department (pentru apeluri rapide)

        Returns:
            tuple: (email, department) sau (None, None)
        """
        email, department, _, _ = self.get_user_info()
        return email, department

    def is_session_valid(self):
        """
        Verifică rapid dacă sesiunea este validă

        Returns:
            bool: True dacă sesiunea este OK
        """
        error_response, _ = self.validate_and_recover_session()
        return error_response is None

    def get_session_info(self):
        """
        Returnează informații complete despre sesiune pentru debugging

        Returns:
            dict: Informații sesiune
        """
        email, department, IdConsultant, IdNivel = self.get_user_info()

        return {
            "user_email": email,
            "department": department,
            "IdConsultant": IdConsultant,
            "IdNivel": IdNivel,
            "session_valid": email is not None,
            "has_department": department is not None,
        }


# ========== CONTEXT MANAGER VERSION ==========
# Alternative implementation using context managers for safer connection handling
class SafeSessionManager:
    """Session manager cu gestionare automată a conexiunilor prin context managers"""

    def __init__(self):
        self.current_user = None
        self.current_department = None

    def _get_db_connection(self):
        """Context manager pentru conexiuni DB"""

        class DBConnection:
            def __enter__(self):
                self.conn = get_service_conn()
                self.cursor = self.conn.cursor()
                return self.conn, self.cursor

            def __exit__(self, exc_type, exc_val, exc_tb):
                if hasattr(self, "cursor") and self.cursor:
                    try:
                        self.cursor.close()
                    except Exception as e:
                        logger.error(f"Error closing cursor: {e}")

                if hasattr(self, "conn") and self.conn:
                    try:
                        self.conn.close()
                    except Exception as e:
                        logger.error(f"Error closing connection: {e}")

        return DBConnection()

    # def _recover_department_from_db(self, email):
    #     """Versiune cu context manager pentru recuperarea departmentului"""
    #     try:
    #         with self._get_db_connection() as (conn, cursor):
    #             query = "SELECT Departament FROM SVN_00.Consultanti WHERE cMail = %s"
    #             cursor.execute(query, (email,))
    #             result = cursor.fetchone()
    #             return result[0] if result and result[0] else None

    #     except Exception as e:
    #         logger.error(f"❌ Eroare la recuperarea departmentului: {e}")
    #         return None

    def get_user_info_safe(self):
        """Versiune cu context manager pentru informații utilizator"""
        if not self.current_user or not self.current_department:
            email = session.get("user")
            department = session.get("department")
        else:
            email = self.current_user
            department = self.current_department

        if not email or not department:
            return None, None, None, None

        try:
            with self._get_db_connection() as (conn, cursor):
                query = """
                    SELECT IdConsultant, IdNivel 
                    FROM SVN_00.Consultanti 
                    WHERE cMail = %s AND Ascuns = 0 AND Plecat = 0
                """
                cursor.execute(query, (email,))
                result = cursor.fetchone()

                if not result:
                    return None, None, None, None

                IdConsultant = result[0]
                IdNivel = result[1] if result[1] else 1

                return email, department, IdConsultant, IdNivel

        except Exception as e:
            logger.error(f"❌ Eroare la obținerea informațiilor utilizator: {e}")
            return None, None, None, None


# ========== FUNCȚII DE COMPATIBILITATE ==========
# Pentru a nu strica codul existent, exportă funcțiile ca înainte


def validate_and_recover_session():
    """Funcție de compatibilitate - wrapper pentru SessionManager"""
    manager = SessionManager()
    return manager.validate_and_recover_session()


def get_user_info():
    """Funcție de compatibilitate - wrapper pentru SessionManager"""
    manager = SessionManager()
    return manager.get_user_info()


# ========== DEBUGGING UTILITIES ==========


def diagnose_connection_pool():
    """Funcție pentru diagnosticarea stării pool-ului de conexiuni"""
    try:
        # Încearcă să obții o conexiune pentru test
        conn = get_service_conn()
        cursor = conn.cursor()

        # Test simplu
        cursor.execute("SELECT 1")
        result = cursor.fetchone()

        cursor.close()
        conn.close()

        logger.info("✅ Test conexiune DB reușit")
        return True

    except Exception as e:
        logger.error(f"❌ Test conexiune DB eșuat: {e}")
        return False


# ========== EXAMPLE USAGE ==========
if __name__ == "__main__":
    # Exemplu de utilizare
    manager = SessionManager()

    # Test conectivitate
    if diagnose_connection_pool():
        logger.info("Conexiune DB OK")

        # Verifică sesiunea
        error, code = manager.validate_and_recover_session()
        if error:
            logger.error("Sesiune invalida: %s", error)
        else:
            logger.info("Sesiune valida")

            # Obține informații utilizator
            info = manager.get_session_info()
            logger.info("Info utilizator: %s", info)

            # Verifică permisiuni
            if manager.check_user_permissions(required_level=2):
                logger.info("Are permisiuni avansate")
            else:
                logger.info("Permisiuni de baza")
    else:
        logger.error("Probleme cu conexiunea DB")
