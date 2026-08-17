#!/bin/bash
# =============================================================================
# ADCREDIT3 - Setup initial server Linux (Ubuntu 22.04 / 24.04)
# Rulează o singură dată pe serverul nou.
# =============================================================================

set -e  # oprește la prima eroare

# ---------- Config ----------
APP_USER="root"
APP_DIR="/root/ADCREDIT3"
VENV_DIR="$APP_DIR/.venv"
LOG_DIR="/var/log/adcredit3"
SERVICE_NAME="adcredit3"
PYTHON="python3.13"

echo "============================================"
echo " ADCREDIT3 - Setup server"
echo "============================================"

# ---------- 1. Dependențe sistem ----------
echo ""
echo "[1/9] Instalez dependențe sistem..."
apt-get update -qq
apt-get install -y -qq \
    software-properties-common \
    curl wget git nginx redis-server \
    build-essential libssl-dev libffi-dev \
    python3-pip python3-venv

# Python 3.13 (deadsnakes PPA)
add-apt-repository -y ppa:deadsnakes/ppa
apt-get update -qq
apt-get install -y -qq python3.13 python3.13-venv python3.13-dev

# Node.js 20 LTS (pentru build-uri viitoare dacă e nevoie)
if ! command -v node &>/dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y -qq nodejs
fi

echo "  Python: $($PYTHON --version)"
echo "  Node:   $(node --version)"
echo "  Redis:  $(redis-server --version | head -1)"

# ---------- 2. User aplicație ----------
echo ""
echo "[2/9] Rulează ca root - user OK."

# ---------- 3. Director aplicație ----------
echo ""
echo "[3/9] Pregătesc directorul $APP_DIR..."
mkdir -p "$LOG_DIR"
chmod 750 "$LOG_DIR"
echo "  Gata."

# ---------- 4. Copiez/clonez codul ----------
echo ""
echo "[4/9] Copiez codul..."
echo "  OPȚIUNE A: dacă ai git repo privat, descomenteaza linia de mai jos:"
# git clone git@github.com:TU/adcredit3.git "$APP_DIR"
echo ""
echo "  OPȚIUNE B (implicita): copiaza codul manual cu rsync de pe Windows:"
echo ""
echo "    rsync -avz --exclude='.venv' --exclude='node_modules' --exclude='__pycache__' \\"
echo "          --exclude='*.pyc' --exclude='.env' --exclude='logs/' \\"
echo "          -e 'ssh -p PORT' /mnt/d/ADCREDIT3/ user@SERVER_IP:$APP_DIR/"
echo ""
read -p "  Codul este deja copiat în $APP_DIR? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "  Copiaza codul si rulează din nou scriptul."
    exit 1
fi

# ---------- 5. Configurare .env ----------
echo ""
echo "[5/9] Configurez .env..."
if [ ! -f "$APP_DIR/.env" ]; then
    if [ -f "$APP_DIR/deploy/.env.production.example" ]; then
        cp "$APP_DIR/deploy/.env.production.example" "$APP_DIR/.env"
        echo "  Creat .env din template. EDITEAZĂ ACUM valorile!"
        nano "$APP_DIR/.env"
    else
        echo "  EROARE: Nu găsesc deploy/.env.production.example"
        echo "  Creează manual $APP_DIR/.env înainte să continui."
        exit 1
    fi
else
    echo "  .env există deja."
fi
chmod 600 "$APP_DIR/.env"

# ---------- 6. Virtual environment Python ----------
echo ""
echo "[6/9] Creez virtual environment Python..."
$PYTHON -m venv "$VENV_DIR"
"$VENV_DIR/bin/pip" install --upgrade pip -q
"$VENV_DIR/bin/pip" install -r "$APP_DIR/requirements.txt" -q
"$VENV_DIR/bin/pip" install gunicorn -q
echo "  Gata. Gunicorn: $("$VENV_DIR/bin/gunicorn" --version)"

# ---------- 7. Redis ----------
echo ""
echo "[7/9] Configurez Redis..."

# Seteaza parola Redis din .env
REDIS_PASS=$(grep "^REDIS_PASSWORD=" "$APP_DIR/.env" | cut -d'=' -f2 | tr -d ' ')
if [ -n "$REDIS_PASS" ]; then
    # Adaugă requirepass în redis.conf dacă nu există deja
    if ! grep -q "^requirepass" /etc/redis/redis.conf; then
        echo "requirepass $REDIS_PASS" >> /etc/redis/redis.conf
        echo "  Parola Redis setată."
    else
        sed -i "s/^requirepass .*/requirepass $REDIS_PASS/" /etc/redis/redis.conf
        echo "  Parola Redis actualizată."
    fi
fi

systemctl enable redis-server
systemctl restart redis-server
echo "  Redis pornit."

# ---------- 8. Systemd service ----------
echo ""
echo "[8/9] Instalez serviciul systemd..."
cp "$APP_DIR/deploy/adcredit3.service" /etc/systemd/system/
systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl start "$SERVICE_NAME"
sleep 2
systemctl status "$SERVICE_NAME" --no-pager -l
echo "  Serviciu pornit."

# ---------- 9. Nginx ----------
echo ""
echo "[9/9] Configurez Nginx..."
cp "$APP_DIR/deploy/nginx-adcredit3.conf" /etc/nginx/sites-available/adcredit3
ln -sf /etc/nginx/sites-available/adcredit3 /etc/nginx/sites-enabled/adcredit3
rm -f /etc/nginx/sites-enabled/default

nginx -t && systemctl restart nginx
echo "  Nginx pornit."

# ---------- Final ----------
echo ""
echo "============================================"
echo " SETUP COMPLET!"
echo "============================================"
echo ""
echo " Aplicatie:  http://$(hostname -I | awk '{print $1}')"
echo " Logs app:   journalctl -u adcredit3 -f"
echo " Logs nginx: tail -f /var/log/nginx/adcredit3-error.log"
echo " Logs app:   tail -f $LOG_DIR/app.log"
echo ""
echo " Update aplicatie:  $APP_DIR/deploy/update.sh"
echo ""
