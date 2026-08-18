# modules/vba_mailer.py
"""SMTP sender - replaces the CDO.Message module in the Access client."""

import os
import ssl
import smtplib
import logging
from email.message import EmailMessage
from dotenv import load_dotenv

load_dotenv()

SMTP_HOST = os.getenv("SMTP_HOST", "mail.svncredit.ro")
SMTP_PORT = int(os.getenv("SMTP_PORT", 465))
SMTP_USER = os.getenv("SMTP_USER", "")
SMTP_PASSWORD = os.getenv("SMTP_PASSWORD", "")
SMTP_FROM = os.getenv("SMTP_FROM", SMTP_USER)

logger = logging.getLogger("mailer")


def send_mail(subject, to_address, body_html, priority_high=False):
    """Send an HTML email. Returns True on success, False on failure."""
    if not to_address:
        logger.warning("send_mail called with empty recipient")
        return False

    try:
        msg = EmailMessage()
        msg["Subject"] = subject
        msg["From"] = SMTP_FROM
        msg["To"] = to_address

        if priority_high:
            msg["X-Priority"] = "1"
            msg["Importance"] = "high"

        msg.set_content("Acest mesaj necesita un client de email cu suport HTML.")
        msg.add_alternative(body_html, subtype="html")

        context = ssl.create_default_context()

        # Port 465 uses implicit TLS; 587 would use STARTTLS instead
        with smtplib.SMTP_SSL(SMTP_HOST, SMTP_PORT, context=context, timeout=20) as server:
            server.login(SMTP_USER, SMTP_PASSWORD)
            server.send_message(msg)

        logger.info(f"Mail sent to {to_address}: {subject}")
        return True

    except Exception as e:
        logger.error(f"Mail to {to_address} failed: {e}")
        return False


def test_smtp():
    """Verify SMTP credentials without sending anything."""
    try:
        context = ssl.create_default_context()
        with smtplib.SMTP_SSL(SMTP_HOST, SMTP_PORT, context=context, timeout=20) as server:
            server.login(SMTP_USER, SMTP_PASSWORD)
        logger.info("SMTP credentials OK")
        return True
    except Exception as e:
        logger.error(f"SMTP check failed: {e}")
        return False