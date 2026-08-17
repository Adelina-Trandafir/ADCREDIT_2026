import smtplib
import os
import logging
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

from dotenv import load_dotenv
load_dotenv()


def send_email(to_addr: str, subject: str, body_html: str) -> bool:
    """Trimite un email via SMTP. Returnează True dacă a reușit."""
    smtp_host = os.getenv("SMTP_HOST", "")
    smtp_port = int(os.getenv("SMTP_PORT", "587"))
    smtp_user = os.getenv("SMTP_USER", "")
    smtp_pass = os.getenv("SMTP_PASS", "")
    smtp_from = os.getenv("SMTP_FROM") or smtp_user

    if not smtp_host or not smtp_user or not smtp_pass:
        logging.getLogger("mailer").error("❌ SMTP neconfigurat în .env (SMTP_HOST/SMTP_USER/SMTP_PASS lipsesc)")
        return False

    try:
        msg = MIMEMultipart("alternative")
        msg["Subject"] = subject
        msg["From"] = smtp_from
        msg["To"] = to_addr
        msg.attach(MIMEText(body_html, "html", "utf-8"))

        with smtplib.SMTP(smtp_host, smtp_port, timeout=10) as smtp:
            smtp.ehlo()
            smtp.starttls()
            smtp.login(smtp_user, smtp_pass)
            smtp.sendmail(smtp_from, [to_addr], msg.as_string())

        logging.getLogger("mailer").info(f"✅ Email trimis la {to_addr} | Subiect: {subject}")
        return True

    except Exception as e:
        logging.getLogger("mailer").error(f"💥 Eroare trimitere email către {to_addr}: {e}")
        return False
