from flask import (
    Blueprint,
)

from typing import List, Dict, Any, Tuple

column_settings_bp = Blueprint("column_settings", __name__)


def _get_IdConsultant(conn, email: str) -> int:
    with conn.cursor() as cur:
        cur.execute(
            "SELECT IdConsultant FROM SVN_00.Consultanti WHERE cMail = %s", (email,)
        )
        row = cur.fetchone()
        if not row:
            raise ValueError("Utilizator inexistent.")
        return row[0]


def _build_columns_config(
    available: List[Tuple], personal: List[Tuple]
) -> List[Dict[str, Any]]:
    personal_map = {
        p[0]: {
            "afisare": p[1],
            "pozitie": p[2],
            "marime": p[3],
            "aliniere": p[4],
            "formatare": p[5],
            "special": p[6],
            "ascuns": p[7],
        }
        for p in personal
    }

    out = []
    for col in available:
        id_col = col[0]
        if id_col in personal_map:
            p = personal_map[id_col]
            out.append(
                {
                    "IdColoana": id_col,
                    "NumeColoana": col[1],
                    "Afisare": p["afisare"],
                    "Pozitie": p["pozitie"],
                    "Marime": p["marime"],
                    "Aliniere": p["aliniere"],
                    "Formatare": p["formatare"],
                    "Special": p["special"],
                    "Ascuns": p["ascuns"],
                    "IsPersonalized": True,
                }
            )
        else:
            out.append(
                {
                    "IdColoana": id_col,
                    "NumeColoana": col[1],
                    "Afisare": col[2],
                    "Pozitie": len(out) + 1,
                    "Marime": col[3] or 100,
                    "Aliniere": col[4] or 0,
                    "Formatare": col[5],
                    "Special": col[6],
                    "Ascuns": 0,
                    "IsPersonalized": False,
                }
            )
    return out


def save_column_settings(
    conn, department: str, email: str, sel_tab: str, columns: List[Dict]
):
    IdConsultant = _get_IdConsultant(conn, email)

    with conn.cursor() as cur:
        cur.execute(
            f"DELETE FROM {department}.Consultanti_Coloane WHERE IdConsultant = %s AND SelTab = %s",
            (IdConsultant, sel_tab),
        )

        insert_sql = f"""
            INSERT INTO {department}.Consultanti_Coloane
            (IdConsultant, SelTab, IdColoana, Afisare, Pozitie, Marime,
             Aliniere, Formatare, Special, Ascuns, DataModificare)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW())
        """
        for c in columns:
            cur.execute(
                insert_sql,
                (
                    IdConsultant,
                    sel_tab,
                    c.get("IdColoana"),
                    c.get("Afisare", 1),
                    c.get("Pozitie", 1),
                    c.get("Marime", 100),
                    c.get("Aliniere", 0),
                    c.get("Formatare"),
                    c.get("Special", 0),
                    c.get("Ascuns", 0),
                ),
            )
    conn.commit()


def load_column_settings(
    conn, department: str, email: str, sel_tab: str
) -> Dict[str, Any]:
    IdConsultant = _get_IdConsultant(conn, email)

    with conn.cursor() as cur:
        cur.execute(
            f"""
            SELECT IdColoana, NumeColoana, AfisareColoana, MarimeInitiala,
                   AliniereInitiala, FormatareInitiala, Special, PozitieInitiala
            FROM {department}.Coloane_Implicite
            WHERE SelTab = %s
            ORDER BY PozitieInitiala
            """,
            (sel_tab,),
        )
        available = cur.fetchall()

        cur.execute(
            f"""
            SELECT IdColoana, Afisare, Pozitie, Marime, Aliniere,
                   Formatare, Special, Ascuns
            FROM {department}.Consultanti_Coloane
            WHERE IdConsultant = %s AND SelTab = %s
            ORDER BY Pozitie
            """,
            (IdConsultant, sel_tab),
        )
        personal = cur.fetchall()

    return {
        "success": True,
        "columns": _build_columns_config(available, personal),
        "selTab": sel_tab,
        "consultant": IdConsultant,
    }


# services/column_settings.py
def reset_column_settings(conn, department: str, email: str, sel_tab: str):
    IdConsultant = _get_IdConsultant(conn, email)

    try:
        conn.autocommit = False  # început tranzacție
        with conn.cursor() as cur:
            # 1. Șterge setările existente
            cur.execute(
                f"""
                DELETE FROM {department}.Consultanti_Coloane
                WHERE IdConsultant = %s AND SelTab = %s
                """,
                (IdConsultant, sel_tab),
            )

            # 2. Re-inserează valorile implicite
            cur.execute(
                f"""
                INSERT INTO {department}.Consultanti_Coloane
                (IdConsultant, SelTab, IdColoana,
                 Afisare, Pozitie, Marime,
                 Aliniere, Formatare, Special, Ascuns, DataModificare)
                SELECT
                    %s,
                    %s,
                    ci.IdColoana,
                    ci.AfisareColoana,
                    ci.PozitieInitiala,
                    ci.MarimeInitiala,
                    ci.AliniereInitiala,
                    ci.FormatareInitiala,
                    ci.Special,
                    0,
                    NOW()
                FROM {department}.Coloane_Implicite ci
                WHERE ci.SelTab = %s
                """,
                (IdConsultant, sel_tab, sel_tab),
            )
        conn.commit()  # finalizează tranzacția
    except Exception:
        conn.rollback()  # anulează orice modificare
        raise
    finally:
        conn.autocommit = True  # restabilește comportamentul implicit


def load_available_columns(conn, department: str, sel_tab: str) -> Dict[str, Any]:
    """
    Returnează doar coloanele implicite pentru un tab dat.
    """
    with conn.cursor() as cur:
        cur.execute(
            f"""
            SELECT IdColoana, NumeColoana, AfisareColoana, MarimeInitiala,
                   AliniereInitiala, FormatareInitiala, Special, PozitieInitiala,
                   '' as Descriere
            FROM {department}.Coloane_Implicite
            WHERE SelTab = %s
            ORDER BY PozitieInitiala ASC
            """,
            (sel_tab,),
        )
        rows = cur.fetchall()

    columns = [
        {
            "IdColoana": row[0],
            "NumeColoana": row[1],
            "AfisareImplicita": row[2],
            "MarimeImplicita": row[3] or 100,
            "AliniereImplicita": row[4] or 0,
            "FormatareImplicita": row[5],
            "TipSpecial": row[6],
            "PozitieImplicita": row[7],
            "Descriere": row[8],
        }
        for row in rows
    ]
    return {"success": True, "columns": columns, "selTab": sel_tab}
