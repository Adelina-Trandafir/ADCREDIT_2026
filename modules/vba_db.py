# modules/vba_db.py
"""Connection pool for the VBA API layer (Access client)."""

import os
import logging
from mysql.connector import pooling
from dotenv import load_dotenv

load_dotenv()

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", 3306))
DB_NAME = os.getenv("DB_NAME", "SVN_00")

DB_VBA_USER = os.getenv("DB_VBA_USER", "flask_user")
DB_VBA_PASSWORD = os.getenv("DB_VBA_PASSWORD", "")

logger = logging.getLogger("db_vba")

# Dedicated pool - kept separate from the service pool so the VBA layer
# can be revoked or throttled without touching the web dashboard
vba_pool = pooling.MySQLConnectionPool(
    pool_name="vba_pool",
    pool_size=3,
    pool_reset_session=True,
    host=DB_HOST,
    port=DB_PORT,
    user=DB_VBA_USER,
    password=DB_VBA_PASSWORD,
    database=DB_NAME,
    charset="utf8mb4",
    collation="utf8mb4_unicode_ci",
    autocommit=False,
)


def get_vba_conn():
    """Return a connection from the VBA pool."""
    return vba_pool.get_connection()


def test_vba_connection():
    """Verify the flask_user account works and has the expected grants."""
    conn = None
    cursor = None
    try:
        conn = get_vba_conn()
        cursor = conn.cursor()
        cursor.execute("SELECT CURRENT_USER(), CONNECTION_ID()")
        row = cursor.fetchone()
        logger.info(f"VBA pool OK - user={row[0]} conn_id={row[1]}")
        return True
    except Exception as e:
        logger.error(f"VBA pool FAILED: {e}")
        return False
    finally:
        if cursor:
            try: cursor.close()
            except Exception: pass
        if conn:
            try: conn.close()
            except Exception: pass