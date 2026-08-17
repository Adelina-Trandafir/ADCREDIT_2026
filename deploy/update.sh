#!/bin/bash
# =============================================================================
# ADCREDIT3 - Script update aplicatie pe server
# Rulează de fiecare dată când depui cod nou.
# =============================================================================

set -e

APP_DIR="/root/ADCREDIT3"
VENV_DIR="$APP_DIR/.venv"
SERVICE_NAME="adcredit3"
APP_USER="root"

echo "============================================"
echo " ADCREDIT3 - Update aplicatie"
echo "============================================"

# Verifică că suntem pe server ca root (sau sudo)
if [ "$(id -u)" -ne 0 ]; then
    echo "Rulează cu sudo."
    exit 1
fi

# ---------- 1. Copiaza codul nou (de pe Windows cu rsync) ----------
echo ""
echo "[1/4] Sincronizare cod..."
echo ""
echo "  Rulează ACUM de pe Windows (local):"
echo ""
echo "    rsync -avz --checksum \\"
echo "          --exclude='.venv' --exclude='node_modules' --exclude='__pycache__' \\"
echo "          --exclude='*.pyc' --exclude='.env' --exclude='logs/' \\"
echo "          --exclude='dump.rdb' --exclude='deploy/' \\"
echo "          -e 'ssh -p PORT' /mnt/d/ADCREDIT3/ user@SERVER_IP:$APP_DIR/"
echo ""
read -p "  Codul a fost copiat? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Anulat."
    exit 0
fi

# ---------- 2. Update dependențe Python ----------
echo ""
echo "[2/4] Update pachete Python..."
"$VENV_DIR/bin/pip" install -r "$APP_DIR/requirements.txt" -q
echo "  Gata."

# ---------- 3. Fix permisiuni ----------
echo ""
echo "[3/4] Corectez permisiunile..."
chmod 600 "$APP_DIR/.env"
echo "  Gata."

# ---------- 4. Restart serviciu ----------
echo ""
echo "[4/4] Restart aplicatie..."
systemctl restart "$SERVICE_NAME"
sleep 2
systemctl status "$SERVICE_NAME" --no-pager -l

echo ""
echo "============================================"
echo " UPDATE COMPLET!"
echo "============================================"
echo ""
echo " Logs live: journalctl -u adcredit3 -f"
echo ""
