// js/components/dashboard/add-lead-modal/add-lead-phone-formatter.js
/**
 * 📱 ADD LEAD PHONE FORMATTER MIXIN
 * Input mask pentru numere de telefon cu formatare automată
 * ✅ V2: Suport pentru lungimi VARIABILE (min/max)
 *
 * @version 2.0.0
 */

export const addLeadPhoneFormatterMixin = {
  /**
   * Pattern-uri de formatare pentru țările EU
   * ⚠️ minDigits/maxDigits = cifre DUPĂ dial code
   */
  phonePatterns: {
    // Țări cu lungimi FIXE
    RO: { dialCode: '+40', pattern: 'XXX XXX XXX', minDigits: 9, maxDigits: 9 },
    BE: { dialCode: '+32', pattern: 'XXX XXX XXX', minDigits: 9, maxDigits: 9 },
    BG: { dialCode: '+359', pattern: 'XX XXX XXXX', minDigits: 9, maxDigits: 9 },
    HR: { dialCode: '+385', pattern: 'XX XXX XXXX', minDigits: 9, maxDigits: 9 },
    CY: { dialCode: '+357', pattern: 'XX XXXXXX', minDigits: 8, maxDigits: 8 },
    CZ: { dialCode: '+420', pattern: 'XXX XXX XXX', minDigits: 9, maxDigits: 9 },
    DK: { dialCode: '+45', pattern: 'XX XX XX XX', minDigits: 8, maxDigits: 8 },
    EE: { dialCode: '+372', pattern: 'XXXX XXXX', minDigits: 7, maxDigits: 8 },
    FI: { dialCode: '+358', pattern: 'XX XXX XXXX', minDigits: 9, maxDigits: 9 },
    FR: { dialCode: '+33', pattern: 'X XX XX XX XX', minDigits: 9, maxDigits: 9 },
    GR: { dialCode: '+30', pattern: 'XXX XXX XXXX', minDigits: 10, maxDigits: 10 },
    HU: { dialCode: '+36', pattern: 'XX XXX XXXX', minDigits: 8, maxDigits: 9 },
    IE: { dialCode: '+353', pattern: 'XX XXX XXXX', minDigits: 9, maxDigits: 9 },
    IT: { dialCode: '+39', pattern: 'XXX XXX XXXX', minDigits: 9, maxDigits: 10 },
    LV: { dialCode: '+371', pattern: 'XX XXX XXX', minDigits: 8, maxDigits: 8 },
    LT: { dialCode: '+370', pattern: 'XXX XXXXX', minDigits: 8, maxDigits: 8 },
    LU: { dialCode: '+352', pattern: 'XXX XXX XXX', minDigits: 9, maxDigits: 9 },
    MT: { dialCode: '+356', pattern: 'XX XX XX XX', minDigits: 8, maxDigits: 8 },
    NL: { dialCode: '+31', pattern: 'X XXXX XXXX', minDigits: 9, maxDigits: 9 },
    PL: { dialCode: '+48', pattern: 'XXX XXX XXX', minDigits: 9, maxDigits: 9 },
    PT: { dialCode: '+351', pattern: 'XXX XXX XXX', minDigits: 9, maxDigits: 9 },
    SK: { dialCode: '+421', pattern: 'XXX XXX XXX', minDigits: 9, maxDigits: 9 },
    SI: { dialCode: '+386', pattern: 'XX XXX XXX', minDigits: 8, maxDigits: 8 },
    ES: { dialCode: '+34', pattern: 'XXX XXX XXX', minDigits: 9, maxDigits: 9 },
    SE: { dialCode: '+46', pattern: 'XX XXX XX XX', minDigits: 9, maxDigits: 9 },

    // Țări cu lungimi VARIABILE
    AT: { dialCode: '+43', pattern: 'XXXX XXXXXX', minDigits: 4, maxDigits: 13 }, // Austria: 4-13 cifre
    DE: { dialCode: '+49', pattern: 'XXX XXXXXXXX', minDigits: 10, maxDigits: 11 }, // Germania: 10-11 (mobile 11)
  },

  /**
   * Inițializează input mask-ul pentru telefon
   */
  initializePhoneInputMask() {
    if (!this.phoneInputElement) {
      this.log.error('❌ Phone input element nu există');
      return;
    }

    // Setează prefixul inițial pentru România
    this.applyPhoneMask('RO');

    // Listeners pentru input
    this.addDOMListener(this.phoneInputElement, 'keydown', (e) => this.handlePhoneKeydown(e));
    this.addDOMListener(this.phoneInputElement, 'input', (e) => this.handlePhoneInput(e));
    this.addDOMListener(this.phoneInputElement, 'paste', (e) => this.handlePhonePasteWithMask(e));
    this.addDOMListener(this.phoneInputElement, 'click', (e) => this.handlePhoneClick(e));
    this.addDOMListener(this.phoneInputElement, 'focus', (e) => this.handlePhoneFocus(e));

    this.log('✅ Phone input mask inițializat');
  },

  /**
   * Aplică mask-ul pentru țara selectată
   */
  applyPhoneMask(countryCode) {
    const pattern = this.phonePatterns[countryCode];

    if (!pattern) {
      this.log.error(`❌ Pattern lipsă pentru ${countryCode}`);
      return;
    }

    // Setează prefixul + un spațiu
    this.phoneInputElement.value = `${pattern.dialCode} `;
    this.phoneInputElement.dataset.prefix = pattern.dialCode;
    this.phoneInputElement.dataset.pattern = pattern.pattern;
    this.phoneInputElement.dataset.minDigits = pattern.minDigits;
    this.phoneInputElement.dataset.maxDigits = pattern.maxDigits;

    // Poziționează cursorul după prefix
    const prefixLength = pattern.dialCode.length + 1; // +1 pentru spațiu
    this.phoneInputElement.setSelectionRange(prefixLength, prefixLength);

    this.log(
      `✅ Mask aplicat pentru ${countryCode}: ${pattern.dialCode} (${pattern.minDigits}-${pattern.maxDigits} cifre)`
    );
  },

  /**
   * Handler pentru keydown - blochează modificarea prefixului
   */
  handlePhoneKeydown(e) {
    const input = e.target;
    const prefix = input.dataset.prefix;
    const prefixLength = prefix.length + 1; // +1 pentru spațiu
    const cursorPos = input.selectionStart;

    // ✅ La Enter, validează și SUBMIT către server
    if (e.key === 'Enter') {
      e.preventDefault();

      // Clear debounce dacă există
      if (this.validationTimeout) {
        clearTimeout(this.validationTimeout);
      }

      // ✅ DOAR LA ENTER - validare + submit către server
      this.handlePhoneSubmit();
      return;
    }

    // 🚫 Ignoră primul 0 pentru România
    if (prefix === '+40') {
      const prefixLength = prefix.length + 1; // +1 pentru spațiu
      const currentDigits = this.extractDigits(input.value.substring(prefixLength));

      // dacă e prima cifră tastată și e 0 -> ignoră
      if (currentDigits.length === 0 && e.key === '0') {
        e.preventDefault();
        return;
      }
    }
    // Blochează modificarea prefixului
    if (cursorPos < prefixLength) {
      // Permite doar navigare și delete/backspace dacă cursorul e după prefix
      if (!['ArrowLeft', 'ArrowRight', 'Home', 'End', 'Tab'].includes(e.key)) {
        e.preventDefault();

        // Dacă e Delete sau Backspace, mută cursorul după prefix
        if (e.key === 'Backspace' || e.key === 'Delete') {
          input.setSelectionRange(prefixLength, prefixLength);
        }

        // Dacă e cifră, inserează după prefix
        if (/^\d$/.test(e.key)) {
          const currentDigits = this.extractDigits(input.value.substring(prefixLength));
          const maxDigits = parseInt(input.dataset.maxDigits);

          if (currentDigits.length < maxDigits) {
            input.value = prefix + ' ' + e.key;
            this.formatPhoneNumber(input);
          }
        }
      }
      return;
    }

    // Permite doar cifre, Backspace, Delete, Arrow keys
    if (
      !/^\d$/.test(e.key) &&
      !['Backspace', 'Delete', 'ArrowLeft', 'ArrowRight', 'Home', 'End', 'Tab'].includes(e.key)
    ) {
      e.preventDefault();
    }

    // Verifică limita de cifre (doar maxDigits)
    if (/^\d$/.test(e.key)) {
      const currentDigits = this.extractDigits(input.value.substring(prefixLength));
      const maxDigits = parseInt(input.dataset.maxDigits);

      if (currentDigits.length >= maxDigits) {
        e.preventDefault();
      }
    }
  },

  /**
   * Handler pentru input - formatează + validează cu debounce
   */
  handlePhoneInput(e) {
    const input = e.target;
    this.formatPhoneNumber(input);

    // ✅ Validare cu debounce de 300ms
    if (this.validationTimeout) {
      clearTimeout(this.validationTimeout);
    }

    this.validationTimeout = setTimeout(() => {
      this.validatePhoneInputWithLibphonenumber();
    }, 300);
  },
  /**
   * Handler pentru click - protejează prefixul
   */
  handlePhoneClick(e) {
    const input = e.target;
    const prefix = input.dataset.prefix;
    const prefixLength = prefix.length + 1;

    if (input.selectionStart < prefixLength) {
      input.setSelectionRange(prefixLength, prefixLength);
    }
  },

  /**
   * Handler pentru focus - poziționează cursorul
   */
  handlePhoneFocus(e) {
    const input = e.target;
    const prefix = input.dataset.prefix;
    const prefixLength = prefix.length + 1;

    // Dacă inputul e gol sau conține doar prefixul, poziționează la sfârșit
    if (input.value === prefix || input.value === prefix + ' ') {
      input.setSelectionRange(prefixLength, prefixLength);
    }
  },

  /**
   * Handler pentru paste - cu detectare țară și formatare
   */
  handlePhonePasteWithMask(e) {
    e.preventDefault();

    const pastedText = (e.clipboardData || window.clipboardData).getData('text');
    const digits = this.extractDigits(pastedText);

    this.log(`📋 Paste: ${pastedText} → Cifre: ${digits}`);

    if (!digits) {
      this.log('⚠️ Nu conține cifre valide');
      return;
    }

    // Încearcă să detecteze țara din număr
    const detectedCountry = this.detectCountryFromDigits(digits);

    if (detectedCountry) {
      this.log(`🔍 Țară detectată: ${detectedCountry.name}`);

      // Actualizează țara în combobox
      this.selectedCountry = detectedCountry;
      this.countryCombobox.setValue(detectedCountry.code, detectedCountry.name);
      this.countryCombobox.setPrefixIcon(`<span class="fi fi-${detectedCountry.flag}"></span>`);

      // Aplică noul mask
      this.applyPhoneMask(detectedCountry.code);

      // Extrage cifrele fără prefix
      let cleanDigits = digits;
      const dialCodeDigits = detectedCountry.dialCode.replace(/\+/g, '');
      if (cleanDigits.startsWith(dialCodeDigits)) {
        cleanDigits = cleanDigits.substring(dialCodeDigits.length);
      }

      // Setează cifrele în input
      const pattern = this.phonePatterns[detectedCountry.code];
      this.phoneInputElement.value = pattern.dialCode + ' ' + cleanDigits;
      this.formatPhoneNumber(this.phoneInputElement);
    } else {
      this.log('⚠️ Nu pot detecta țara, folosesc țara curentă');

      // Folosește țara curentă și adaugă cifrele
      const pattern = this.phonePatterns[this.selectedCountry.code];
      const dialCodeDigits = pattern.dialCode.replace(/\+/g, '');

      let cleanDigits = digits;
      if (cleanDigits.startsWith(dialCodeDigits)) {
        cleanDigits = cleanDigits.substring(dialCodeDigits.length);
      }

      this.phoneInputElement.value = pattern.dialCode + ' ' + cleanDigits;
      this.formatPhoneNumber(this.phoneInputElement);
    }

    // Validează numărul
    this.validatePhoneInput();
  },

  /**
   * Formatează numărul de telefon conform pattern-ului
   * ✅ Pattern-ul e doar VIZUAL, acceptăm orice lungime între min/max
   */
  formatPhoneNumber(input) {
    const prefix = input.dataset.prefix;
    const pattern = input.dataset.pattern;
    const prefixLength = prefix.length + 1; // +1 pentru spațiu

    // Salvează poziția cursorului
    let cursorPos = input.selectionStart;

    // Extrage doar cifrele (fără prefix)
    const allText = input.value;
    const digitsOnly = this.extractDigits(allText.substring(prefixLength));

    if (!digitsOnly) {
      input.value = prefix + ' ';
      input.setSelectionRange(prefixLength, prefixLength);
      return;
    }

    // Aplică formatare cu spații conform pattern-ului (doar vizual)
    let formatted = '';
    let digitIndex = 0;

    // Folosim pattern-ul doar pentru a știe unde să punem spații
    // DAR acceptăm mai multe cifre decât pattern-ul dacă țara permite
    const maxDigits = parseInt(input.dataset.maxDigits);

    for (
      let i = 0;
      i < pattern.length && digitIndex < digitsOnly.length && digitIndex < maxDigits;
      i++
    ) {
      if (pattern[i] === 'X') {
        formatted += digitsOnly[digitIndex];
        digitIndex++;
      } else {
        formatted += pattern[i];
      }
    }

    // Dacă mai sunt cifre rămase (pentru țări cu lungimi variabile), le adăugăm
    while (digitIndex < digitsOnly.length && digitIndex < maxDigits) {
      formatted += digitsOnly[digitIndex];
      digitIndex++;
    }

    // Setează valoarea formatată
    input.value = prefix + ' ' + formatted;

    // Ajustează poziția cursorului
    const oldSpaces = (allText.substring(0, cursorPos).match(/ /g) || []).length;
    const newSpaces = (input.value.substring(0, cursorPos).match(/ /g) || []).length;

    if (newSpaces > oldSpaces) {
      cursorPos += newSpaces - oldSpaces;
    }

    // Asigură-te că cursorul nu e în prefix
    if (cursorPos < prefixLength) {
      cursorPos = prefixLength;
    }

    // Setează cursorul
    input.setSelectionRange(cursorPos, cursorPos);
  },

  /**
   * Extrage doar cifrele dintr-un string
   */
  extractDigits(str) {
    return str.replace(/\D/g, '');
  },

  /**
   * Detectează țara din cifrele unui număr
   */
  detectCountryFromDigits(digits) {
    // Verifică fiecare țară
    for (const country of this.euCountries) {
      const dialCodeDigits = country.dialCode.replace(/\+/g, '');

      if (digits.startsWith(dialCodeDigits)) {
        return country;
      }
    }

    return null;
  },

  /**
   * Override pentru handleCountrySelect - aplică mask-ul la schimbare țară
   */
  handleCountrySelectWithMask(value, text, data) {
    this.log(`🌍 Țară selectată: ${data?.data?.name || value} (${value})`);

    if (!data || !data.data) {
      this.log.error('❌ Date țară invalide');
      return;
    }

    const country = data.data;
    this.selectedCountry = {
      code: country.code,
      dialCode: country.dialCode,
      flag: country.flag,
      name: country.name,
    };

    // Actualizează steagul în prefix icon
    this.countryCombobox.setPrefixIcon(`<span class="fi fi-${country.flag}"></span>`);

    // Aplică noul mask
    this.applyPhoneMask(country.code);

    // ✅ FOCUS AUTOMAT pe input telefon
    setTimeout(() => {
      this.phoneInputElement.focus();

      // Poziționează cursorul după prefix
      const pattern = this.phonePatterns[country.code];
      if (pattern) {
        const prefixLength = pattern.dialCode.length + 1;
        this.phoneInputElement.setSelectionRange(prefixLength, prefixLength);
      }
    }, 100);

    this.log(
      `✅ Țară actualizată: ${this.selectedCountry.name} (${this.selectedCountry.dialCode}) + FOCUS`
    );
  },

  /**
   * Obține numărul de telefon complet (pentru validare/submit)
   */
  getFormattedPhone() {
    const input = this.phoneInputElement;
    const prefix = input.dataset.prefix;
    const prefixLength = prefix.length + 1;

    const digits = this.extractDigits(input.value.substring(prefixLength));

    if (!digits) {
      return null;
    }

    return prefix + digits; // Ex: +40723456789
  },

  /**
   * ✅ Verifică dacă numărul e VALID (între min și max)
   */
  isPhoneComplete() {
    const input = this.phoneInputElement;
    const prefix = input.dataset.prefix;
    const prefixLength = prefix.length + 1;
    const minDigits = parseInt(input.dataset.minDigits);
    const maxDigits = parseInt(input.dataset.maxDigits);

    const digits = this.extractDigits(input.value.substring(prefixLength));
    const digitCount = digits.length;

    // Valid dacă e între min și max
    return digitCount >= minDigits && digitCount <= maxDigits;
  },
};
