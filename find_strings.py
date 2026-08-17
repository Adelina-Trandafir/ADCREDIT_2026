# find_login_refs.py
# Salvează acest fișier în root-ul proiectului și rulează-l

import os
import re


def find_login_references():
    """Găsește toate referințele la 'login' în proiect"""

    # Pattern-uri de căutat
    patterns = [r"DescriereColoana", r"DescriereColoana2"]

    print("🔍 Caut referințe la 'login' în toate fișierele...\n")

    for root, dirs, files in os.walk("."):
        # Skip acestea
        if any(
            skip in root for skip in ["venv", "__pycache__", ".git", "node_modules"]
        ):
            continue

        for file in files:
            if file.endswith((".py", ".html", ".js")):
                filepath = os.path.join(root, file)

                try:
                    with open(filepath, "r", encoding="utf-8") as f:
                        content = f.read()
                        lines = content.splitlines()

                        for i, line in enumerate(lines, 1):
                            for pattern, desc in patterns:
                                if re.search(pattern, line, re.IGNORECASE):
                                    print(f"📍 {filepath}:{i}")
                                    print(f"   Tip: {desc}")
                                    print(f"   Linie: {line.strip()}")
                                    print(f"   Fix: Schimbă 'login' cu 'auth.login'")
                                    print()

                except Exception as e:
                    pass

    print("\n✅ Căutare completă!")
    print("💡 Înlocuiește toate 'login' cu 'auth.login' în locurile găsite")


if __name__ == "__main__":
    find_login_references()
