/**
 * 🛡️ SECURE ADMIN LOGIN - SISTEM CU PAȘI
 * Flux: Email → Cheie → Parolă → Dashboard
 */
let IdConsultant = null; // ID-ul consultantului validat

class StepByStepAdminLogin {
  constructor() {
    this.form = document.getElementById('adminLoginForm');
    this.loginBtn = document.getElementById('loginBtn');
    this.btnText = this.loginBtn.querySelector('.btn-text');
    this.btnLoader = this.loginBtn.querySelector('.btn-loader');
    this.errorDiv = document.getElementById('errorMessage');
    this.successDiv = document.getElementById('successMessage');

    // Elementele pentru pași
    this.emailInput = document.getElementById('adminEmail');
    this.keyInput = document.getElementById('adminKey');
    this.passwordInput = document.getElementById('adminPassword');

    this.emailIcon = document.getElementById('emailValidationIcon');
    this.keyIcon = document.getElementById('keyValidationIcon');
    this.passwordIcon = document.getElementById('passwordValidationIcon');

    this.step1 = document.getElementById('step1');
    this.step2 = document.getElementById('step2');
    this.step3 = document.getElementById('step3');

    // Starea curentă
    this.currentStep = 1;
    this.isProcessing = false;
    this.validatedData = {};

    this.init();
  }

  init() {
    // console.log('🚀 Inițializez Step-by-Step Admin Login...');

    // Setează starea inițială
    this.setupInitialState();

    // Event listeners
    this.setupEventListeners();

    // Focus pe primul câmp
    this.emailInput.focus();

    // console.log('✅ Step-by-Step Admin Login inițializat');
  }

  /**
   * 🔒 Setează starea inițială: doar Email activ
   */
  setupInitialState() {
    // Email rămâne type=email; cheie și parolă sunt ascunse
    this.emailInput.type = 'email';
    this.keyInput.type = 'password';
    this.passwordInput.type = 'password';

    // Doar Email-ul este activ
    this.emailInput.disabled = false;
    this.keyInput.disabled = true;
    this.passwordInput.disabled = true;

    // Butoanele de vizibilitate
    this.updateVisibilityButtons();

    // Butonul de submit
    this.loginBtn.disabled = true;

    // Progress steps
    this.updateProgressSteps();

    // console.log('🔒 Stare inițială setată: doar Email activ');
  }

  /**
   * 🎯 Event listeners pentru fiecare pas
   */
  setupEventListeners() {
    // Email validation (în timp real)
    this.emailInput.addEventListener('input', () => {
      this.clearMessages();
      this.validateEmailInput();
    });

    this.emailInput.addEventListener('blur', () => {
      if (this.emailInput.value.trim() && this.currentStep === 1) {
        this.validateEmailWithServer();
      }
    });

    // Key validation
    this.keyInput.addEventListener('input', () => {
      this.clearMessages();
      this.validateKeyInput();
    });

    this.keyInput.addEventListener('blur', () => {
      if (this.keyInput.value.trim() && this.currentStep === 2) {
        this.validateKeyWithServer();
      }
    });

    // Password validation
    this.passwordInput.addEventListener('input', () => {
      this.clearMessages();
      this.validatePasswordInput();
    });

    // Enter key navigation
    this.emailInput.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && this.currentStep === 1) {
        e.preventDefault();
        this.validateEmailWithServer();
      }
    });

    this.keyInput.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && this.currentStep === 2) {
        e.preventDefault();
        this.validateKeyWithServer();
      }
    });

    this.passwordInput.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && this.currentStep === 3) {
        e.preventDefault();
        this.handleFinalSubmit();
      }
    });

    // Form submit
    this.form.addEventListener('submit', (e) => {
      e.preventDefault();
      this.handleFinalSubmit();
    });

    // Keyboard shortcuts
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        this.clearMessages();
      }
    });
  }

  /**
   * 📧 PASUL 1: Validare Email
   */
  validateEmailInput() {
    const email = this.emailInput.value.trim();

    if (!email) {
      this.emailIcon.textContent = '';
      this.emailIcon.className = 'validation-icon';
      return;
    }

    // Validare simplă (fără structură email pentru admin)
    if (email.length >= 3) {
      this.emailIcon.textContent = '⏳';
      this.emailIcon.className = 'validation-icon checking';
    } else {
      this.emailIcon.textContent = '❌';
      this.emailIcon.className = 'validation-icon error';
    }
  }

  async validateEmailWithServer() {
    const email = this.emailInput.value.trim();

    if (!email || email.length < 3) {
      this.showError('Introduceți email-ul administrator!');
      return;
    }

    try {
      this.setProcessing(true);
      this.emailIcon.textContent = '⏳';
      this.emailIcon.className = 'validation-icon checking';

      console.log('🔍 Verifică email în DB:', email);

      const response = await fetch('/admin/api/check-email', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email }),
        credentials: 'same-origin',
      });

      const data = await response.json();

      if (data.exists == true) {
        // Email valid - activează pasul 2
        this.validatedData.email = email;
        this.emailIcon.textContent = '✅';
        this.emailIcon.className = 'validation-icon success';
        this.advanceToStep(2);

        IdConsultant = data.IdConsultant; // Păstrează ID-ul consultantului

        console.log('✅ Email valid, avanc la pasul 2');
      } else {
        // Email invalid
        this.emailIcon.textContent = '❌';
        this.emailIcon.className = 'validation-icon error';
        this.showError(data.message || 'Email-ul nu există în sistem');
        this.setStepError(1);
      }
    } catch (error) {
      console.error('❌ Eroare verificare email:', error);
      this.emailIcon.textContent = '❌';
      this.emailIcon.className = 'validation-icon error';
      this.showError('Eroare de conexiune la verificarea email-ului');
      this.setStepError(1);
    } finally {
      this.setProcessing(false);
    }
  }

  /**
   * 🔑 PASUL 2: Validare Cheie
   */
  validateKeyInput() {
    const key = this.keyInput.value.trim();

    if (!key) {
      this.keyIcon.textContent = '';
      this.keyIcon.className = 'validation-icon';
      return;
    }

    if (key.length >= 10) {
      this.keyIcon.textContent = '⏳';
      this.keyIcon.className = 'validation-icon checking';
    } else {
      this.keyIcon.textContent = '❌';
      this.keyIcon.className = 'validation-icon error';
    }
  }

  async validateKeyWithServer() {
    const key = this.keyInput.value.trim();

    if (!key || key.length < 10) {
      this.showError('Introduceți cheia specială admin!');
      return;
    }

    try {
      this.setProcessing(true);
      this.keyIcon.textContent = '⏳';
      this.keyIcon.className = 'validation-icon checking';

      console.log('🔑 Verifică cheie admin');

      const response = await fetch('/admin/api/verify-key', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          admin_key: key,
        }),
        credentials: 'same-origin',
      });

      const data = await response.json();

      if (data.valid == true) {
        // Cheie validă - activează pasul 3
        this.validatedData.admin_key = key;
        this.keyIcon.textContent = '✅';
        this.keyIcon.className = 'validation-icon success';
        this.advanceToStep(3);

        console.log('✅ Cheie validă, avanc la pasul 3');
      } else {
        // Cheie invalidă
        this.keyIcon.textContent = '❌';
        this.keyIcon.className = 'validation-icon error';
        this.showError(data.message || 'Cheia admin este incorectă');
        this.setStepError(2);
      }
    } catch (error) {
      console.error('❌ Eroare verificare cheie:', error);
      this.keyIcon.textContent = '❌';
      this.keyIcon.className = 'validation-icon error';
      this.showError('Eroare de conexiune la verificarea cheii');
      this.setStepError(2);
    } finally {
      this.setProcessing(false);
    }
  }

  /**
   * 🔒 PASUL 3: Validare Parolă
   */
  validatePasswordInput() {
    const password = this.passwordInput.value;

    if (!password) {
      this.passwordIcon.textContent = '';
      this.passwordIcon.className = 'validation-icon';
      this.loginBtn.disabled = true;
      return;
    }

    if (password.length >= 8) {
      this.passwordIcon.textContent = '✅';
      this.passwordIcon.className = 'validation-icon success';
      this.loginBtn.disabled = false;
    } else {
      this.passwordIcon.textContent = '❌';
      this.passwordIcon.className = 'validation-icon error';
      this.loginBtn.disabled = true;
    }
  }

  /**
   * 🚀 PASUL FINAL: Submit complet
   */
  async handleFinalSubmit() {
    const password = this.passwordInput.value;

    if (!password || password.length < 8) {
      this.showError('Introduceți parola administrator!');
      return;
    }

    try {
      this.setProcessing(true);
      this.passwordIcon.textContent = '⏳';
      this.passwordIcon.className = 'validation-icon checking';

      console.log('🔐 Test final conexiune MySQL');

      const response = await fetch('/admin/api/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          IdConsultant: IdConsultant,
          password: password,
        }),
        credentials: 'same-origin',
      });

      const data = await response.json();

      if (data.success) {
        // SUCCESS - toate pașii completați
        this.passwordIcon.textContent = '✅';
        this.passwordIcon.className = 'validation-icon success';
        this.setStepCompleted(3);

        this.showSuccess(data.message || 'Autentificare reușită!');

        // Redirect către dashboard
        setTimeout(() => {
          window.location.href = data.redirect || '/admin/dashboard';
        }, 1500);
      } else {
        // Eroare la autentificare
        this.passwordIcon.textContent = '❌';
        this.passwordIcon.className = 'validation-icon error';
        this.showError(data.message || 'Parolă incorectă');
        this.setStepError(3);
      }
    } catch (error) {
      console.error('❌ Eroare login final:', error);
      this.passwordIcon.textContent = '❌';
      this.passwordIcon.className = 'validation-icon error';
      this.showError('Eroare de conexiune la autentificare');
      this.setStepError(3);
    } finally {
      this.setProcessing(false);
    }
  }

  /**
   * 🔄 Avansează la următorul pas
   */
  advanceToStep(stepNumber) {
    this.currentStep = stepNumber;

    if (stepNumber === 2) {
      // Activează câmpul pentru cheie
      this.keyInput.disabled = false;
      this.keyInput.focus();
      this.setStepCompleted(1);
      this.setStepActive(2);
    } else if (stepNumber === 3) {
      // Activează câmpul pentru parolă
      this.passwordInput.disabled = false;
      this.passwordInput.focus();
      this.setStepCompleted(2);
      this.setStepActive(3);
    }

    this.updateVisibilityButtons();
    this.updateProgressSteps();
  }

  /**
   * 🎯 Actualizează butoanele de vizibilitate
   */
  updateVisibilityButtons() {
    const buttons = document.querySelectorAll('.visibility-toggle');
    buttons.forEach((button, index) => {
      const input = [this.emailInput, this.keyInput, this.passwordInput][index];
      button.disabled = input.disabled;
    });
  }

  /**
   * 📊 Actualizează progress steps
   */
  updateProgressSteps() {
    // Reset toate
    [this.step1, this.step2, this.step3].forEach((step) => {
      step.className = 'step';
    });

    // Setează starea curentă
    const currentStepEl = [this.step1, this.step2, this.step3][this.currentStep - 1];
    currentStepEl.classList.add('active');

    // Marchează pașii completați
    for (let i = 1; i < this.currentStep; i++) {
      const stepEl = [this.step1, this.step2, this.step3][i - 1];
      stepEl.classList.add('completed');
    }
  }

  setStepActive(stepNumber) {
    const stepEl = [this.step1, this.step2, this.step3][stepNumber - 1];
    stepEl.className = 'step active';
  }

  setStepCompleted(stepNumber) {
    const stepEl = [this.step1, this.step2, this.step3][stepNumber - 1];
    stepEl.className = 'step completed';
  }

  setStepError(stepNumber) {
    const stepEl = [this.step1, this.step2, this.step3][stepNumber - 1];
    stepEl.classList.add('error');
  }

  /**
   * 🔄 Loading state management
   */
  setProcessing(processing) {
    this.isProcessing = processing;

    if (processing) {
      this.btnText.style.display = 'none';
      this.btnLoader.style.display = 'inline';
    } else {
      this.btnText.style.display = 'inline';
      this.btnLoader.style.display = 'none';
    }
  }

  /**
   * 💬 Mesaje către utilizator
   */
  showError(message) {
    this.clearMessages();
    this.errorDiv.textContent = message;
    this.errorDiv.style.display = 'block';

    setTimeout(() => {
      this.errorDiv.style.display = 'none';
    }, 8000);
  }

  showSuccess(message) {
    this.clearMessages();
    this.successDiv.textContent = message;
    this.successDiv.style.display = 'block';
  }

  clearMessages() {
    this.errorDiv.style.display = 'none';
    this.successDiv.style.display = 'none';
  }
}

/**
 * 🔥 FUNCȚIE GLOBALĂ pentru toggle vizibilitate
 */
function toggleVisibility(inputId) {
  const input = document.getElementById(inputId);
  const button = input?.parentElement?.querySelector('.visibility-toggle');

  if (!input || !button || button.disabled) {
    return;
  }

  if (input.type === 'password') {
    input.type = 'text';
    button.textContent = '🙈';
    button.title = 'Ascunde';
  } else {
    input.type = 'password';
    button.textContent = '👁️';
    button.title = 'Arată';
  }
}

/**
 * 🚀 INIȚIALIZARE
 */
function initializeStepByStepLogin() {
  // console.log('🚀 Inițializez Step-by-Step Admin Login...');
  console.log('Document readyState:', document.readyState);

  const requiredElements = [
    'adminLoginForm',
    'adminEmail',
    'adminKey',
    'adminPassword',
    'loginBtn',
    'errorMessage',
    'successMessage',
    'emailValidationIcon',
    'keyValidationIcon',
    'passwordValidationIcon',
    'step1',
    'step2',
    'step3',
  ];

  requiredElements.forEach((id) => {
    const element = document.getElementById(id);
    // console.log(`Element ${id}:`, element ? 'Found' : 'Not Found');
  });

  const missingElements = requiredElements.filter((id) => !document.getElementById(id));

  if (missingElements.length > 0) {
    console.error('❌ Lipsesc elementele:', missingElements);
    return;
  }

  new StepByStepAdminLogin();
  console.log('✅ Step-by-Step Admin Login inițializat cu succes!');
}

// Inițializare la încărcarea DOM
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeStepByStepLogin);
} else {
  initializeStepByStepLogin();
}

// Debug info
// console.log('📄 admin-login.js (Step-by-Step) încărcat!');
