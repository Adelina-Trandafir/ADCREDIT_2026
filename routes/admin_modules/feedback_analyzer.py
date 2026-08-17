"""
Feedback Analyzer — hybrid rule-based keyword analysis (Romanian).
Designed to work with zero external dependencies.
Extensible: swap analyze_text() with an LLM call when Ollama/API is available.
"""
from collections import defaultdict

# ---- Keyword sets → category tags (Romanian) ----
PATTERNS = {
    # Consultant behavior — negative
    "consultant_comunicare_slaba": [
        "nu a raspuns", "nu raspunde", "nu a sunat", "nu suna",
        "nu a contactat", "nu a revenit", "nu a mai dat semn",
        "fara raspuns", "nu se poate contacta", "nu a trimis",
        "nu a explicat", "explicatii insuficiente", "nu a informat",
        "nu a transmis", "nu a anuntat",
    ],
    "consultant_agresiv": [
        "agresiv", "nepoliticos", "jignit", "insultat", "iritat",
        "nervos", "ton ridicat", "tonul", "grosolanie", "neplacut",
        "suparat pe", "a tipat", "a urlat", "a amenintat",
    ],
    "consultant_nepregătit": [
        "nu stia", "nu cunoaste", "nu cunostea", "nu a stiut", "nu stie",
        "informatii gresite", "eroare", "confuz", "neclaritati", "gresit",
        "nu cunostea produsul", "nu a putut explica",
    ],
    # Consultant behavior — positive
    "consultant_pozitiv": [
        "profesionist", "amabil", "politicos", "a ajutat", "multumit de consultant",
        "a explicat bine", "very good", "excellent", "foarte bun", "recomandat",
        "a rezolvat", "prompt", "eficient", "dedicat",
    ],
    # Client behavior
    "client_refuz_credit": [
        "nu vrea credit", "nu doreste", "nu mai doreste", "renuntat",
        "s-a razgandit", "nu e interesat", "nu are nevoie",
        "nu mai e interesat", "refuza", "nu vrea sa mai", "a renuntat",
        "nu vrea sa contracteze", "nu vrea sa semneze",
    ],
    "client_informatii_insuficiente": [
        "nu a dat date", "nu ofera", "nu vrea sa dea", "refuza sa dea",
        "nu coopereaza", "nu raspunde la intrebari", "evita",
        "nu are actele", "nu are documentele", "documente lipsa",
        "acte lipsa", "nu trimite actele", "nu poate prezenta",
    ],
    "client_probleme_financiare": [
        "restante", "restanta", "datorii", "biroul de credit",
        "birou de credit", "rata neplatita", "rate neplatite",
        "executare", "poprire", "insolventa", "faliment",
        "pensie mica", "salariu mic", "venit insuficient",
        "nu indeplineste conditiile", "scoring slab",
    ],
    "client_contact_imposibil": [
        "nu raspunde la telefon", "numarul nu exista", "numar gresit",
        "telefon inchis", "nu este disponibil", "nu ridica",
        "mesagerie", "nu poate fi contactat", "nr incorect",
        "numar invalid", "disconnected",
    ],
    # Lead quality
    "lead_calitate_slaba": [
        "date gresite", "numar gresit", "adresa gresita", "nu exista",
        "lead invalid", "spam", "fals", "date false", "test",
        "nu este real", "dosar fals",
    ],
    # Positive outcomes
    "oportunitate_buna": [
        "interesat", "doreste", "vrea credit", "accepta", "a acceptat",
        "semnat", "aprobat", "debursare", "dosar depus", "dosar aprobat",
        "a semnat contractul", "a primit creditul", "client multumit",
    ],
}

TAG_LABELS = {
    "consultant_comunicare_slaba": "Comunicare slabă",
    "consultant_agresiv": "Comportament agresiv",
    "consultant_nepregătit": "Nepregătit profesional",
    "consultant_pozitiv": "Feedback pozitiv",
    "client_refuz_credit": "Client refuză creditul",
    "client_informatii_insuficiente": "Client fără documente",
    "client_probleme_financiare": "Probleme financiare client",
    "client_contact_imposibil": "Client imposibil de contactat",
    "lead_calitate_slaba": "Lead de calitate slabă",
    "oportunitate_buna": "Oportunitate bună",
}


def analyze_text(text: str) -> dict:
    """Analyze a single feedback text, return dict of {tag: hit_count}."""
    if not text:
        return {}
    text_lower = text.lower()
    tags = {}
    for tag, keywords in PATTERNS.items():
        count = sum(1 for kw in keywords if kw in text_lower)
        if count > 0:
            tags[tag] = count
    return tags


def analyze_consultant_feedbacks(feedbacks: list) -> list:
    """
    Aggregate per-consultant analysis from a list of feedback rows.

    Expected row keys: IdConsultant, NumeConsultant, Feedback, FelStatus, DataConectare
    Returns sorted list of per-consultant dicts with insights.
    """
    consultants: dict = defaultdict(lambda: {
        "NumeConsultant": "",
        "total_feedback": 0,
        "tags": defaultdict(int),
    })

    for row in feedbacks:
        cid = row.get("IdConsultant")
        if not cid:
            continue
        c = consultants[cid]
        c["NumeConsultant"] = row.get("NumeConsultant") or f"Consultant {cid}"
        c["total_feedback"] += 1

        text = row.get("Feedback") or ""
        for tag, score in analyze_text(text).items():
            c["tags"][tag] += score

    result = []
    for cid, data in consultants.items():
        tags = dict(data["tags"])
        total = data["total_feedback"]

        insights = _build_insights(tags, total)

        score_neg = (
            tags.get("consultant_comunicare_slaba", 0)
            + tags.get("consultant_agresiv", 0)
            + tags.get("consultant_nepregătit", 0)
        )
        score_pos = (
            tags.get("consultant_pozitiv", 0)
            + tags.get("oportunitate_buna", 0)
        )

        # Top tags by count (for bar display)
        top_tags = sorted(tags.items(), key=lambda x: x[1], reverse=True)[:5]

        result.append({
            "IdConsultant": cid,
            "NumeConsultant": data["NumeConsultant"],
            "total_feedback": total,
            "tags": tags,
            "top_tags": [{"tag": t, "label": TAG_LABELS.get(t, t), "count": c} for t, c in top_tags],
            "insights": insights,
            "score_pozitiv": score_pos,
            "score_negativ": score_neg,
        })

    result.sort(key=lambda x: x["total_feedback"], reverse=True)
    return result


def analyze_single_feedbacks(feedbacks: list) -> list:
    """Tag individual feedback records for drill-down view."""
    result = []
    for row in feedbacks:
        text = row.get("Feedback") or ""
        tags = analyze_text(text)
        top_tags = sorted(tags.items(), key=lambda x: x[1], reverse=True)[:3]
        result.append({
            "IdFeedBack": row.get("IdFeedBack"),
            "FelStatus": row.get("FelStatus", ""),
            "DataConectare": str(row.get("DataConectare", "")),
            "Feedback": text[:300] + ("…" if len(text) > 300 else ""),
            "tags": [{"tag": t, "label": TAG_LABELS.get(t, t)} for t, _ in top_tags],
        })
    return result


def _build_insights(tags: dict, total: int) -> list:
    insights = []
    if tags.get("consultant_comunicare_slaba", 0) >= 2:
        insights.append({"type": "warning", "msg": "Comunicare insuficientă cu clienții"})
    if tags.get("consultant_agresiv", 0) >= 1:
        insights.append({"type": "danger", "msg": "Comportament agresiv semnalat"})
    if tags.get("consultant_nepregătit", 0) >= 2:
        insights.append({"type": "warning", "msg": "Pregătire profesională insuficientă"})
    if tags.get("consultant_pozitiv", 0) >= 3:
        insights.append({"type": "success", "msg": "Feedback pozitiv consistent"})
    if total > 0 and tags.get("client_refuz_credit", 0) / total > 0.25:
        insights.append({"type": "info", "msg": "Mulți clienți renunță la credit"})
    if tags.get("client_informatii_insuficiente", 0) >= 2:
        insights.append({"type": "info", "msg": "Clienți care nu furnizează documente"})
    if tags.get("client_contact_imposibil", 0) >= 3:
        insights.append({"type": "info", "msg": "Clienți greu de contactat"})
    if tags.get("client_probleme_financiare", 0) >= 2:
        insights.append({"type": "info", "msg": "Clienți cu probleme financiare frecvente"})
    if tags.get("lead_calitate_slaba", 0) >= 2:
        insights.append({"type": "warning", "msg": "Lead-uri de calitate slabă în portofoliu"})
    if tags.get("oportunitate_buna", 0) >= 5:
        insights.append({"type": "success", "msg": "Rată bună de conversie a clienților"})
    if not insights:
        insights.append({"type": "neutral", "msg": "Fără semnale semnificative detectate"})
    return insights
