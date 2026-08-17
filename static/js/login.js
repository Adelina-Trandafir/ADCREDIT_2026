// ========== LOGIN.JS ==========
import { Combobox } from './components/combobox/combobox.js';

document.addEventListener('DOMContentLoaded', function () {
  // Elemente DOM
  const form = document.getElementById('loginForm');
  const emailInput = document.getElementById('email');
  const departmentContainer = document.getElementById('departmentContainer');
  const passwordInput = document.getElementById('password');
  const loginButton = document.getElementById('loginButton');
  const loadingSpinner = document.getElementById('loadingSpinner');
  const errorMessage = document.getElementById('errorMessage');
  const infoMessage = document.getElementById('infoMessage');

  // Status elements
  const emailStatus = document.getElementById('emailStatus');
  const departmentStatus = document.getElementById('departmentStatus');
  const passwordStatus = document.getElementById('passwordStatus');

  // State variables
  let emailValidated = false;
  let departmentsLoaded = false;
  let currentUserData = null;
  let selectedDepartment = '';

  // 2FA state
  const twoFaSection  = document.getElementById('twoFaSection');
  const twoFaCode     = document.getElementById('twoFaCode');
  const twoFaButton   = document.getElementById('twoFaButton');
  const twoFaSpinner  = document.getElementById('twoFaSpinner');
  const twoFaStatus   = document.getElementById('twoFaStatus');
  const twoFaCancelLink = document.getElementById('twoFaCancelLink');

  // Mapare baze de date pentru afișare user-friendly
  const databaseMap = {
    SVN_IM:  'Ipotecare',
    SVN_NP:  'Nevoi Personale',
    SVN_AS:  'Asigurări',
    SVN_TEST: 'Testing',
    ADMIN:   '⚙️ Administrare',
  };

  const debugMode = false; // Activează logarea pentru debugging
  /**
   * Log pentru debugging - Format pentru fișiere non-class
   */
  const log = (() => {
    const fn = (message, data = null) => {
      if (debugMode) {
        const now = new Date();
        const ts = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now
          .getMilliseconds()
          .toString()
          .padStart(3, '0')}`;
        const CPN = 'LOGIN'.padEnd(15);
        console.log(
          `%c[${ts}] [${CPN}] ${message}`,
          'color: #b5f1ffff; font-weight: bold;',
          data ?? ''
        );
      }
    };

    fn.error = (message, data = null) => {
      const now = new Date();
      const ts = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now
        .getMilliseconds()
        .toString()
        .padStart(3, '0')}`;
      const CPN = 'LOGIN'.padEnd(15);
      console.error(
        `%c[${ts}] [${CPN}] ${message}`,
        'color: #ef4444; font-weight: bold;',
        data ?? ''
      );
    };

    return fn;
  })();

  // Polyfill ZIndexManager pentru paginile care nu îl încarcă
  if (!window.ZIndexManager) {
    let _z = 100;
    window.ZIndexManager = { getNext: () => ++_z };
  }

  // ========== COMBOBOX DEPARTMENT ==========
  const departmentCombobox = new Combobox(departmentContainer, {
    placeholder: 'Introduceți mai întâi emailul...',
    readonly: true,
    staticData: [],
    showLoader: false,
    onSelect: (value, text) => {
      departmentSelected(value, text);
    },
  });
  departmentCombobox.setEnabled(false);

  // Monkey-patch: fix dropdown position + width (positionDropdown() never called by component)
  const _origShow = departmentCombobox.show.bind(departmentCombobox);
  departmentCombobox.show = function () {
    _origShow();
    departmentCombobox.positionDropdown();
    const rect = departmentContainer.getBoundingClientRect();
    departmentCombobox.dropdown.style.width = rect.width + 'px';
    departmentCombobox.dropdown.style.maxWidth = 'none';
  };

  // ========== EMAIL VALIDATION ==========
  function validateEmailInput() {
    const email = this.value.trim();

    if (!email) {
      resetEmailValidation();
      return;
    }

    if (!isValidEmail(email)) {
      showEmailError('Format email invalid');
      return;
    }

    // Verifică emailul în backend
    checkEmailInDatabase(email);
  }

  function resetEmailInput() {
    // Reset la schimbarea email-ului
    if (emailValidated) {
      resetEmailValidation();
      resetDepartmentSelect();
    }
  }

  function departmentSelected(value) {
    selectedDepartment = value;

    if (value === 'ADMIN') {
      departmentStatus.textContent = '⚙️ Administrare selectată — va fi solicitat cod 2FA';
      departmentStatus.className = 'field-status info';
      departmentContainer.classList.add('combobox-valid');
    } else if (value) {
      departmentStatus.textContent = `✅ Bază de date selectată: ${databaseMap[value] || value}`;
      departmentStatus.className = 'field-status success';
      departmentContainer.classList.add('combobox-valid');
    } else {
      departmentStatus.textContent = '';
      departmentStatus.className = 'field-status';
      departmentContainer.classList.remove('combobox-valid');
    }

    updateLoginButtonState();
  }

  function passwordValidating() {
    const password = passwordInput.value;

    if (password.length >= 10) {
      passwordStatus.textContent = '✅ Parolă introdusă';
      passwordStatus.className = 'field-status success';
      passwordInput.classList.add('valid');
    } else {
      passwordStatus.textContent = '';
      passwordStatus.className = 'field-status';
      passwordInput.classList.remove('valid');
    }

    updateLoginButtonState();
  }

  // ========== EMAIL VALIDATION ==========
  emailInput.addEventListener('blur', validateEmailInput);
  emailInput.addEventListener('change', validateEmailInput);
  emailInput.addEventListener('keydown', function (e) {
    if (e.key === 'Enter') {
      e.preventDefault();
      validateEmailInput.call(this);
    }
  });

  emailInput.addEventListener('input', resetEmailInput);

  // ========== PASSWORD VALIDATION ==========
  passwordInput.addEventListener('input', passwordValidating);

  // ========== FORM SUBMISSION ==========
  form.addEventListener('submit', async function (e) {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    await performLogin();
  });

  // ========== HELPER FUNCTIONS ==========

  function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  async function checkEmailInDatabase(email) {
    log(`🔍 Checking email: ${email}`);

    // Show loading state
    emailStatus.textContent = '🔄 Verificare email...';
    emailStatus.className = 'field-status info';
    emailInput.classList.remove('valid', 'invalid');
      log(email, '📤 Sent email check request');

    try {
      const response = await fetch('/api/check-email', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email: email }),
      });
      const data = await response.json();

      if (data.exists) {
        log('✅ Email found in database');

        // Salvează datele utilizatorului
        currentUserData = data;

        // Email valid
        emailStatus.textContent = '✅ Email găsit în sistem';
        emailStatus.className = 'field-status success';
        emailInput.classList.add('valid');
        emailValidated = true;

        // Verifică statusul parolei
        if (data.parola_resetata === 1) {
          showInfoMessage(
            '⚠️ Parola a fost resetată. Veți fi redirectat către pagina de schimbare parolă după autentificare.'
          );
        }

        // Încarcă bazele de date disponibile
        await loadAvailableDepartments(data.departmente_disponibile);

        // Deschide automat dropdown-ul pentru selecție rapidă
        if (data.departmente_disponibile.length > 1) {
          setTimeout(() => {
            departmentCombobox.input.focus();
            departmentCombobox.input.click();
          }, 500); // Mic delay pentru UX
        }
      } else {
        log.error('❌ Email not found');
        showEmailError('Email-ul nu este înregistrat în sistem');
      }
    } catch (error) {
      log.error('💥 Error checking email:', error);
      showEmailError('Eroare la verificarea email-ului. Încercați din nou.');
    }
  }

  async function loadAvailableDepartments(departmenteDisponibile) {
    log(`📂 Loading databases: ${departmenteDisponibile}`);

    departmentStatus.textContent = '🔄 Încărcare baze de date...';
    departmentStatus.className = 'field-status info';

    try {
      if (!departmenteDisponibile || departmenteDisponibile.length === 0) {
        throw new Error('Nu sunt definite baze de date pentru acest utilizator');
      }

      // Construiește lista de opțiuni
      const items = departmenteDisponibile.map((db) => ({
        value: db,
        label: databaseMap[db] || db,
      }));

      // Dacă utilizatorul are nivel admin (>=40), adaugă opțiunea Administrare
      if (currentUserData && currentUserData.IdNivel >= 40) {
        items.push({ value: 'ADMIN', label: '⚙️ Administrare' });
      }

      departmentCombobox.options.staticData = items;
      departmentCombobox.setEnabled(true);
      departmentsLoaded = true;

      // Update status
      if (departmenteDisponibile.length === 1) {
        // Dacă este o singură bază de date, selectează-o automat
        const v = departmenteDisponibile[0];
        departmentCombobox.setValue(v, databaseMap[v] || v);
        selectedDepartment = v;
        departmentContainer.classList.add('combobox-valid');
        departmentStatus.textContent = `✅ Bază de date auto-selectată: ${databaseMap[v] || v}`;
        departmentStatus.className = 'field-status success';
      } else {
        departmentStatus.textContent = `📋 ${departmenteDisponibile.length} baze de date disponibile`;
        departmentStatus.className = 'field-status info';
      }

      log(`✅ Loaded ${departmenteDisponibile.length} databases`);
    } catch (error) {
      log.error('💥 Error loading databases:', error);
      departmentStatus.textContent = `❌ ${error.message}`;
      departmentStatus.className = 'field-status error';
      departmentCombobox.setEnabled(false);
      departmentsLoaded = false;
    }

    updateLoginButtonState();
  }

  function resetEmailValidation() {
    emailValidated = false;
    emailStatus.textContent = '';
    emailStatus.className = 'field-status';
    emailInput.classList.remove('valid', 'invalid');
    hideMessages();
    resetDepartmentSelect();
  }

  function resetDepartmentSelect() {
    selectedDepartment = '';
    departmentCombobox.options.staticData = [];
    departmentCombobox.clear();
    departmentCombobox.setEnabled(false);
    departmentContainer.classList.remove('combobox-valid');
    departmentsLoaded = false;
    departmentStatus.textContent = '';
    departmentStatus.className = 'field-status';
    updateLoginButtonState();
  }

  function showEmailError(message) {
    emailValidated = false;
    emailStatus.textContent = `❌ ${message}`;
    emailStatus.className = 'field-status error';
    emailInput.classList.add('invalid');
    resetDepartmentSelect();
    updateLoginButtonState();
  }

  function validateForm() {
    const email = emailInput.value.trim();
    const password = passwordInput.value.trim();

    // Verificări complete
    if (!email) {
      showErrorMessage('Introduceți adresa de email');
      emailInput.focus();
      return false;
    }

    if (!emailValidated) {
      showErrorMessage('Email-ul nu a fost validat. Apăsați Tab după introducerea email-ului.');
      emailInput.focus();
      return false;
    }

    if (!selectedDepartment) {
      showErrorMessage('Selectați serviciu');
      departmentCombobox.input.focus();
      return false;
    }

    if (!password) {
      showErrorMessage('Introduceți parola');
      passwordInput.focus();
      return false;
    }

    if (password.length < 3) {
      showErrorMessage('Parola trebuie să aibă cel puțin 3 caractere');
      passwordInput.focus();
      return false;
    }

    return true;
  }

  async function performLogin() {
    log('🔐 Attempting login...');

    // Show loading state
    setLoadingState(true);
    hideMessages();

    const formData = {
      email: emailInput.value.trim(),
      password: passwordInput.value.trim(),
      department: selectedDepartment,
    };

    try {
      const response = await fetch('/api/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });

      const data = await response.json();

      if (data.success && data.requires_totp_setup) {
        log('🔐 TOTP setup required');
        showTotpSetup(data.qr_b64, data.secret);
      } else if (data.success && data.requires_2fa) {
        log('🔐 TOTP verify required');
        showTwoFaSection();
      } else if (data.success) {
        log('✅ Login successful');
        showInfoMessage('✅ Autentificare reușită! Redirectare...');
        setTimeout(() => {
          window.location.href = data.redirect || '/dashboard';
        }, 1000);
      } else {
        log.error('❌ Login failed:', data.message);

        // Verifică dacă este problemă cu parola resetată
        if (data.message && data.message.includes('resetată')) {
          showInfoMessage(`⚠️ ${data.message}`);

          // Dacă este parolă resetată, redirectează la verificare K1
          if (data.redirect) {
            setTimeout(() => {
              window.location.href = data.redirect;
            }, 2000);
          }
        } else {
          showErrorMessage(data.message || 'Email sau parolă incorecte');
        }

        // Reset password field
        passwordInput.value = '';
        passwordInput.classList.remove('valid');
        passwordStatus.textContent = '';
        passwordInput.focus();
      }
    } catch (error) {
      log.error('💥 Login error:', error);
      showErrorMessage(
        'Eroare de conexiune. Verificați conexiunea la internet și încercați din nou.'
      );
    } finally {
      setLoadingState(false);
    }
  }

  function updateLoginButtonState() {
    const password = passwordInput.value.trim();

    const isFormValid = emailValidated && departmentsLoaded && selectedDepartment && password.length >= 3;

    loginButton.disabled = !isFormValid;

    if (isFormValid) {
      loginButton.textContent = '🚀 Conectare';
    } else {
      if (!emailValidated) {
        loginButton.textContent = '📧 Introduceți emailul';
      } else if (!departmentsLoaded || !selectedDepartment) {
        loginButton.textContent = '🗄️ Selectați serviciu';
      } else if (!password || password.length < 3) {
        loginButton.textContent = '🔐 Introduceți parola';
      }
    }
  }

  function setLoadingState(loading) {
    if (loading) {
      loadingSpinner.style.display = 'inline-block';
      loginButton.disabled = true;
      loginButton.textContent = 'Se conectează...';

      // Disable all inputs during loading
      emailInput.disabled = true;
      departmentCombobox.setEnabled(false);
      passwordInput.disabled = true;
    } else {
      loadingSpinner.style.display = 'none';

      // Re-enable inputs
      emailInput.disabled = false;
      if (departmentsLoaded) {
        departmentCombobox.setEnabled(true);
      }
      passwordInput.disabled = false;

      updateLoginButtonState();
    }
  }

  function showErrorMessage(message) {
    errorMessage.textContent = message;
    errorMessage.style.display = 'block';
    infoMessage.style.display = 'none';

    // Scroll to error message
    errorMessage.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  }

  function showInfoMessage(message) {
    infoMessage.textContent = message;
    infoMessage.style.display = 'block';
    errorMessage.style.display = 'none';

    // Scroll to info message
    infoMessage.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  }

  function hideMessages() {
    errorMessage.style.display = 'none';
    infoMessage.style.display = 'none';
  }

  // ========== KEYBOARD SHORTCUTS ==========
  document.addEventListener('keydown', function (e) {
    // Enter key submits form if all fields are valid
    if (e.key === 'Enter' && !loginButton.disabled) {
      e.preventDefault();
      form.dispatchEvent(new Event('submit'));
    }

    // Escape key clears all messages
    if (e.key === 'Escape') {
      hideMessages();
    }
  });

  // ========== 2FA ADMIN ==========

  function showTwoFaSection() {
    form.style.display = 'none';
    hideMessages();
    document.getElementById('totpSetupBlock').style.display = 'none';
    document.getElementById('twoFaLabel').textContent = '🔑 COD DIN APLICAȚIE:';
    showInfoMessage('🔐 Introduceți codul de 6 cifre din aplicația Secure Signin.');
    twoFaSection.style.display = 'block';
    twoFaCode.value = '';
    twoFaStatus.textContent = '';
    twoFaStatus.className = 'field-status';
    twoFaCode.focus();
  }

  function showTotpSetup(qrB64, secret) {
    form.style.display = 'none';
    hideMessages();

    // Afișează QR code și cheia manuală
    const setupBlock = document.getElementById('totpSetupBlock');
    document.getElementById('totpQrImg').src = 'data:image/png;base64,' + qrB64;
    document.getElementById('totpSecretDisplay').textContent = secret;
    setupBlock.style.display = 'block';

    document.getElementById('twoFaLabel').textContent = '🔑 CONFIRMĂ CODUL DIN APLICAȚIE:';
    showInfoMessage('📱 Scanați QR-ul cu Secure Signin, apoi introduceți primul cod generat pentru confirmare.');
    twoFaSection.style.display = 'block';
    twoFaCode.value = '';
    twoFaStatus.textContent = '';
    twoFaStatus.className = 'field-status';
    twoFaCode.focus();
  }

  async function submitTwoFa() {
    const code = twoFaCode.value.trim();
    if (!code || code.length !== 6 || !/^\d{6}$/.test(code)) {
      twoFaStatus.textContent = '❌ Introduceți un cod valid de 6 cifre';
      twoFaStatus.className = 'field-status error';
      return;
    }

    twoFaSpinner.style.display = 'inline-block';
    twoFaButton.disabled = true;
    twoFaStatus.textContent = '🔄 Verificare cod...';
    twoFaStatus.className = 'field-status info';

    try {
      const response = await fetch('/verify-admin-totp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ code }),
      });
      const data = await response.json();

      if (data.success) {
        twoFaStatus.textContent = '✅ Cod corect! Redirectare...';
        twoFaStatus.className = 'field-status success';
        setTimeout(() => { window.location.href = data.redirect || '/admin/dashboard'; }, 800);
      } else {
        twoFaStatus.textContent = `❌ ${data.message}`;
        twoFaStatus.className = 'field-status error';
        twoFaCode.value = '';
        twoFaCode.focus();
        twoFaButton.disabled = false;
      }
    } catch (err) {
      log.error('💥 2FA error:', err);
      twoFaStatus.textContent = '❌ Eroare de conexiune. Încercați din nou.';
      twoFaStatus.className = 'field-status error';
      twoFaButton.disabled = false;
    } finally {
      twoFaSpinner.style.display = 'none';
    }
  }

  function cancelTwoFa() {
    twoFaSection.style.display = 'none';
    form.style.display = 'block';
    hideMessages();
    passwordInput.value = '';
    passwordInput.classList.remove('valid');
    passwordStatus.textContent = '';
    updateLoginButtonState();
  }

  // Event listeners 2FA
  twoFaButton.addEventListener('click', submitTwoFa);
  twoFaCancelLink.addEventListener('click', (e) => { e.preventDefault(); cancelTwoFa(); });
  twoFaCode.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') { e.preventDefault(); e.stopPropagation(); submitTwoFa(); }
  });

  // ========== INITIAL STATE ==========
  updateLoginButtonState();

  // Dacă URL-ul conține ?step=2fa, afișează direct secțiunea 2FA
  // (utilizator deja logat normal, vrea să acceseze Admin Dashboard)
  const urlParams = new URLSearchParams(window.location.search);
  if (urlParams.get('step') === '2fa') {
    showTwoFaSection();
    showInfoMessage('🔐 Introduceți codul de 6 cifre din aplicația Secure Signin pentru acces admin.');
  } else {
    // Focus pe primul input doar dacă nu suntem în modul 2FA
    emailInput.focus();
  }

  log('✅ Login page initialized');
});
