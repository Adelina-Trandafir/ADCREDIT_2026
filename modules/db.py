import os
from mysql.connector import pooling, connect, Error
from dotenv import load_dotenv

import logging

# Load environment variables from .env file
load_dotenv()

# Database configuration from environment
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", 3306))
DB_NAME = os.getenv("DB_NAME", "your_database")

# Service (admin) account credentials
DB_SERVICE_USER = os.getenv("DB_SERVICE_USER", "service_user")
DB_SERVICE_PASSWORD = os.getenv("DB_SERVICE_PASSWORD", "service_password")

# Create a connection pool for the service account
service_pool = pooling.MySQLConnectionPool(
    pool_name="service_pool",
    pool_size=20,
    host=DB_HOST,
    port=DB_PORT,
    user=DB_SERVICE_USER,
    password=DB_SERVICE_PASSWORD,
    database=DB_NAME,
)


def get_service_conn():
    """
    Return a connection from the service (admin) pool.
    Use this for operations requiring elevated privileges.
    """
    return service_pool.get_connection()


def get_user_conn(email: str, password: str):
    """
    NOUA LOGICĂ:
    1. Caută email-ul în tabelul Consultanti cu conexiunea admin
    2. Găsește IdConsultant
    3. Creează username-ul C + padding (ex: C012)
    4. Testează conexiunea cu username-ul generat + parola
    """
    admin_conn = None
    user_conn = None
    cursor = None

    try:
        # Pasul 1: Conectează-te ca admin pentru a căuta email-ul
        admin_conn = get_service_conn()
        cursor = admin_conn.cursor()

        logging.getLogger("db").info(
            f"🔍 Caut email-ul '{email}' în tabelul Consultanti..."
        )

        # Pasul 2: Caută email-ul în tabelul Consultanti
        query = "SELECT IdConsultant FROM SVN_00.Consultanti WHERE cMail = %s"
        cursor.execute(query, (email,))
        result = cursor.fetchone()

        if not result:
            logging.getLogger("db").info(
                f"❌ Email-ul '{email}' NU a fost găsit în baza de date!"
            )
            raise Error("Email nu există în sistem")

        IdConsultant = result[0]
        logging.getLogger("db").info(f"✅ Email găsit! IdConsultant = {IdConsultant}")

        # Pasul 3: Creează username-ul cu padding (ex: 12 → C012)
        username = f"C{IdConsultant:03d}"  # :03d = padding cu 0 până la 3 cifre
        logging.getLogger("db").info(f"🔑 Username generat: '{username}'")

        # Pasul 4: Testează conexiunea cu username-ul generat + parola
        logging.getLogger("db").info(
            f"🔐 Încerc să mă conectez cu '{username}' + parola introdusă..."
        )

        user_conn = connect(
            host=DB_HOST,
            port=DB_PORT,
            user=username,
            password=password,
            database=DB_NAME,
        )

        logging.getLogger("db").info(f"🎉 Login REUȘIT pentru {username}!")
        return user_conn

    except Error as e:
        logging.getLogger("db").info(f"💥 EROARE la login: {e}")
        # Închide conexiunile dacă sunt deschise
        if user_conn:
            user_conn.close()
        raise

    finally:
        # Închide conexiunea admin (rămâne în pool pentru alte operații)
        if admin_conn:
            admin_conn.close()


def test_connection():
    """
    Funcție de test pentru a verifica dacă conexiunea admin funcționează
    """
    try:
        conn = get_service_conn()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        logging.getLogger("db").info("✅ Conexiunea admin funcționează!")
        return True
    except Error as e:
        logging.getLogger("db").info(f"❌ Conexiunea admin EȘUEAZĂ: {e}")
        return False
