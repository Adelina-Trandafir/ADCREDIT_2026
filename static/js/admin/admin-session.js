/**
 * 🔐 ADMIN SESSION MONITORING
 * Monitorizează sesiunea admin: expirare după 15 minute, maxim 2 prelungiri.
 * Funcționează independent, fără importuri ES modules.
 */
(function () {
  const MAX_EXTENSIONS = 2;
  const WARNING_SECONDS = 60; // Avertisment cu 60 secunde înainte de expirare

  let extensionCount = 0;
  let warningShown = false;
  let expiredRedirecting = false;
  let warningTimer = null;
  let expiryTimer = null;
  let countdownInterval = null;

  /**
   * Inițializează monitorizarea sesiunii admin.
   * Apelează /admin/api/session-info pentru a obține timpul rămas.
   */
  async function init() {
    try {
      const response = await fetch('/admin/api/session-info', { method: 'GET' });
      if (!response.ok) {
        if (response.status === 401) {
          redirectToLogin('Sesiune admin inactivă.');
        }
        return;
      }

      const data = await response.json();
      if (!data.success) {
        redirectToLogin('Sesiune admin inactivă.');
        return;
      }

      const remaining = data.session_data.remaining_seconds;
      extensionCount = data.session_data.extension_count || 0;

      scheduleTimers(remaining * 1000);
    } catch (e) {
      console.error('[AdminSession] Eroare la inițializare:', e);
    }
  }

  /**
   * Programează timer-ele pentru warning și expirare.
   * @param {number} remainingMs - milisecunde rămase
   */
  function scheduleTimers(remainingMs) {
    clearTimers();

    const warningMs = remainingMs - WARNING_SECONDS * 1000;

    if (warningMs > 0) {
      warningTimer = setTimeout(() => showWarning(WARNING_SECONDS), warningMs);
    } else if (remainingMs > 0) {
      // Mai puțin de 60 de secunde rămase → afișează avertismentul imediat
      showWarning(Math.round(remainingMs / 1000));
    }

    expiryTimer = setTimeout(() => handleExpiry(), remainingMs);
  }

  /**
   * Afișează modalul de avertisment înainte de expirare.
   * @param {number} seconds - secunde rămase
   */
  function showWarning(seconds) {
    if (warningShown || expiredRedirecting) return;
    warningShown = true;

    const hasExtensions = extensionCount < MAX_EXTENSIONS;
    const remaining = MAX_EXTENSIONS - extensionCount;

    const modal = document.createElement('div');
    modal.id = 'admin-session-warning-modal';
    modal.style.cssText = `
      position: fixed; inset: 0; z-index: 99999;
      display: flex; align-items: center; justify-content: center;
    `;

    modal.innerHTML = `
      <div style="position:absolute;inset:0;background:rgba(0,0,0,0.55);"></div>
      <div style="
        position:relative; background:#1e293b; color:#f1f5f9;
        border-radius:12px; padding:2rem; max-width:420px; width:90%;
        box-shadow:0 20px 60px rgba(0,0,0,0.5); border:1px solid #334155;
        text-align:center;
      ">
        <div style="font-size:2.5rem;margin-bottom:0.75rem;">⚠️</div>
        <h3 style="margin:0 0 1rem;font-size:1.2rem;color:#fbbf24;">
          Sesiunea admin va expira în curând!
        </h3>
        <p style="margin:0 0 0.5rem;color:#94a3b8;font-size:0.95rem;">
          Timp rămas: <strong style="color:#f1f5f9;" id="admin-session-countdown">${seconds}</strong> secunde
        </p>
        ${hasExtensions ? `
        <p style="margin:0 0 1.5rem;color:#94a3b8;font-size:0.85rem;">
          Prelungiri disponibile: <strong style="color:#60a5fa;">${remaining}/${MAX_EXTENSIONS}</strong>
        </p>
        <button id="admin-extend-btn" style="
          background:#3b82f6; color:#fff; border:none; border-radius:8px;
          padding:0.65rem 1.5rem; font-size:0.95rem; cursor:pointer;
          margin-right:0.75rem; font-weight:600;
        ">🔄 Prelungește sesiunea</button>
        ` : `
        <p style="margin:0 0 1.5rem;color:#f87171;font-size:0.85rem;">
          ⛔ Nu mai sunt prelungiri disponibile. Salvați lucrul!
        </p>
        `}
        <button id="admin-logout-btn" style="
          background:#475569; color:#f1f5f9; border:none; border-radius:8px;
          padding:0.65rem 1.25rem; font-size:0.9rem; cursor:pointer;
        ">🚪 Logout acum</button>
      </div>
    `;

    document.body.appendChild(modal);

    // Countdown
    let remaining_s = seconds;
    countdownInterval = setInterval(() => {
      remaining_s--;
      const el = document.getElementById('admin-session-countdown');
      if (el) el.textContent = remaining_s;
      if (remaining_s <= 0) clearInterval(countdownInterval);
    }, 1000);

    // Butoane
    const extendBtn = document.getElementById('admin-extend-btn');
    if (extendBtn) {
      extendBtn.addEventListener('click', () => attemptExtension(modal));
    }
    const logoutBtn = document.getElementById('admin-logout-btn');
    if (logoutBtn) {
      logoutBtn.addEventListener('click', () => { window.location.href = '/admin/logout'; });
    }
  }

  /**
   * Încearcă prelungirea sesiunii admin.
   */
  async function attemptExtension(modal) {
    try {
      const response = await fetch('/admin/api/extend-session', { method: 'POST' });
      const data = await response.json();

      if (data.success) {
        extensionCount = data.extension_count;
        warningShown = false;
        clearTimers();
        if (countdownInterval) clearInterval(countdownInterval);
        if (modal) modal.remove();

        scheduleTimers(data.new_expires_in * 1000);
      } else {
        // Maxim atins sau eroare
        const extendBtn = document.getElementById('admin-extend-btn');
        if (extendBtn) {
          extendBtn.disabled = true;
          extendBtn.textContent = '⛔ Maxim atins';
          extendBtn.style.background = '#475569';
        }
      }
    } catch (e) {
      console.error('[AdminSession] Eroare la prelungire:', e);
    }
  }

  /**
   * Gestionează expirarea sesiunii.
   */
  function handleExpiry() {
    if (expiredRedirecting) return;
    expiredRedirecting = true;
    clearTimers();
    if (countdownInterval) clearInterval(countdownInterval);

    // Elimină modalul de warning dacă există
    const existingModal = document.getElementById('admin-session-warning-modal');
    if (existingModal) existingModal.remove();

    // Afișează mesaj de expirare
    const expiredMsg = document.createElement('div');
    expiredMsg.style.cssText = `
      position:fixed; inset:0; z-index:999999;
      background:rgba(0,0,0,0.75); display:flex;
      align-items:center; justify-content:center;
    `;
    expiredMsg.innerHTML = `
      <div style="
        background:#1e293b; color:#f1f5f9; border-radius:12px;
        padding:2rem; text-align:center; max-width:380px;
        border:1px solid #ef4444; box-shadow:0 20px 60px rgba(0,0,0,0.5);
      ">
        <div style="font-size:2.5rem;margin-bottom:0.75rem;">🔒</div>
        <h3 style="color:#ef4444;margin:0 0 0.75rem;">Sesiunea admin a expirat!</h3>
        <p style="color:#94a3b8;margin:0 0 1.5rem;font-size:0.9rem;">
          Vă rugăm să vă autentificați din nou.
        </p>
        <p style="color:#60a5fa;font-size:0.85rem;">Redirecționare în 3 secunde...</p>
      </div>
    `;
    document.body.appendChild(expiredMsg);

    setTimeout(() => {
      window.location.href = '/login?admin_expired=1';
    }, 3000);
  }

  function clearTimers() {
    if (warningTimer) { clearTimeout(warningTimer); warningTimer = null; }
    if (expiryTimer)  { clearTimeout(expiryTimer);  expiryTimer  = null; }
  }

  function redirectToLogin(reason) {
    console.warn('[AdminSession]', reason);
    window.location.href = '/login';
  }

  // Pornește monitorizarea la încărcarea paginii
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
