// js/components/dashboard/add-lead-modal/add-lead-validation.js
/**
 * ✅ ADD LEAD VALIDATION MIXIN
 * Validare numere de telefon cu suport pentru lungimi VARIABILE
 * ✅ UPDATE: Range validation (min/max) în loc de lungimi fixe
 *
 * @version 2.0.0
 */

export const addLeadValidationMixin = {
  /**
   * Validează numărul de telefon (cu suport min/max)
   *
   * @param {string} phone - Numărul de telefon formatat (ex: +40723456789)
   * @param {string} countryCode - Codul țării (ex: 'RO')
   * @returns {Object} { isValid: boolean, formatted: string, error: string }
   */
  validatePhone(phone, countryCode) {
    this.log('🔍 Validare număr de telefon:', phone, 'Țară:', countryCode);
    if (!phone) {
      return {
        isValid: false,
        formatted: '',
        error: 'Număr de telefon lipsă',
      };
    }

    // Extrage doar cifrele
    const digits = this.extractDigits(phone);

    // Obține pattern-ul pentru țară
    const pattern = this.phonePatterns[countryCode];

    if (!pattern) {
      return {
        isValid: false,
        formatted: phone,
        error: 'Țară necunoscută',
      };
    }

    // Verifică lungimea (total = dial code digits + subscriber digits)
    const dialCodeDigits = pattern.dialCode.replace(/\+/g, '').length;
    const subscriberDigits = digits.length - dialCodeDigits;

    // ✅ Validare cu RANGE (min/max)
    if (subscriberDigits < pattern.minDigits) {
      return {
        isValid: false,
        formatted: phone,
        error: `Numărul trebuie să aibă minim ${pattern.minDigits} cifre`,
      };
    }

    if (subscriberDigits > pattern.maxDigits) {
      return {
        isValid: false,
        formatted: phone,
        error: `Numărul trebuie să aibă maxim ${pattern.maxDigits} cifre`,
      };
    }

    // Valid!
    return {
      isValid: true,
      formatted: phone,
      error: '',
    };
  },

  /**
   * Validare pentru România (backwards compatibility)
   * România are întotdeauna 9 cifre după +40
   */
  validateRomanianPhone(phone) {
    // Elimină +
    if (phone.startsWith('+')) {
      phone = phone.substring(1);
    }

    // Cazul 1: Începe cu 40
    if (phone.startsWith('40')) {
      phone = phone.substring(2);

      if (phone.length !== 9) {
        return {
          isValid: false,
          formatted: phone,
          error: 'Număr românesc invalid. Format: +40XXXXXXXXX (9 cifre după +40)',
        };
      }

      if (!phone.startsWith('7')) {
        return {
          isValid: false,
          formatted: phone,
          error: 'Număr românesc invalid. Trebuie să înceapă cu 7 după +40',
        };
      }

      return {
        isValid: true,
        formatted: `+40${phone}`,
        error: '',
      };
    }

    // Cazul 2: Începe cu 0
    if (phone.startsWith('0')) {
      if (phone.length !== 10) {
        return {
          isValid: false,
          formatted: phone,
          error: 'Număr românesc invalid. Format: 07XXXXXXXX (10 cifre)',
        };
      }

      if (!phone.startsWith('07')) {
        return {
          isValid: false,
          formatted: phone,
          error: 'Număr românesc invalid. Trebuie să înceapă cu 07',
        };
      }

      return {
        isValid: true,
        formatted: `+40${phone.substring(1)}`,
        error: '',
      };
    }

    // Cazul 3: Direct 9 cifre (pentru mobile)
    if (phone.length === 9 && phone.startsWith('7')) {
      return {
        isValid: true,
        formatted: `+40${phone}`,
        error: '',
      };
    }

    return {
      isValid: false,
      formatted: phone,
      error: 'Număr românesc invalid. Formate acceptate: +40XXXXXXXXX, 07XXXXXXXX',
    };
  },

  /**
   * Validare internațională cu libphonenumber (fallback)
   */
  validateInternationalPhone(phone, countryCode) {
    if (!window.libphonenumber) {
      this.log.error('❌ libphonenumber nu este încărcat');
      return this.validatePhoneSimple(phone);
    }

    try {
      const { parsePhoneNumber } = window.libphonenumber;

      let phoneNumber;

      // Încearcă să parseze cu country code
      try {
        phoneNumber = parsePhoneNumber(phone, countryCode);
      } catch (e) {
        // Dacă nu merge, încearcă direct (dacă începe cu +)
        if (phone.startsWith('+')) {
          phoneNumber = parsePhoneNumber(phone);
        } else {
          throw e;
        }
      }

      // Verifică dacă e valid
      if (!phoneNumber.isValid()) {
        this.log(`⚠️ Număr invalid pentru ${countryCode}: ${phone}`);
        return {
          isValid: false,
          formatted: phone,
          error: `Număr invalid pentru ${countryCode}`,
        };
      }

      const formatted = phoneNumber.format('E.164');

      this.log(`✅ Validare libphonenumber OK: ${phone} → ${formatted}`);

      return {
        isValid: true,
        formatted: formatted,
        error: '',
      };
    } catch (error) {
      this.log.error('❌ Eroare validare libphonenumber:', error);

      // Fallback la validare simplă
      return this.validatePhoneSimple(phone);
    }
  },

  /**
   * ✅ METODĂ NOUĂ - Validare cu libphonenumber
   */
  validatePhoneInputWithLibphonenumber() {
    const phone = this.getFormattedPhone();

    if (!phone) {
      this.clearPhoneError();
      this.setButtonState('ok', false);
      return;
    }

    // Verifică lungimea (min/max) mai întâi
    if (!this.isPhoneComplete()) {
      // Nu arăta eroare dacă utilizatorul încă tastează
      const input = this.phoneInputElement;
      const prefix = input.dataset.prefix;
      const prefixLength = prefix.length + 1;
      const digits = this.extractDigits(input.value.substring(prefixLength));
      const minDigits = parseInt(input.dataset.minDigits);

      if (digits.length > 0 && digits.length < minDigits) {
        this.showPhoneError(`Minim ${minDigits} cifre necesare`);
      } else {
        this.clearPhoneError();
      }

      this.setButtonState('ok', false);
      return;
    }

    // ✅ Validare cu libphonenumber
    const countryCode = this.selectedCountry.code;

    this.log(`🔍 Validez telefon LOCAL: ${phone} pentru ${countryCode}`);

    const validation = this.validateInternationalPhone(phone, countryCode);

    if (validation.isValid) {
      this.clearPhoneError();
      this.currentPhone = validation.formatted;

      this.log(`✅ Telefon VALID: ${validation.formatted}`);
    } else {
      this.showPhoneError(validation.error);
      this.setButtonState('ok', false);

      this.log(`❌ Telefon INVALID: ${validation.error}`);
    }
  },

  /**
   * Validare simplă fallback
   */
  validatePhoneSimple(phone) {
    const cleanPhone = phone.replace(/^\+/, '');

    if (!/^\d+$/.test(cleanPhone)) {
      return {
        isValid: false,
        formatted: phone,
        error: 'Număr de telefon invalid (conține caractere non-numerice)',
      };
    }

    if (cleanPhone.length < 7 || cleanPhone.length > 15) {
      return {
        isValid: false,
        formatted: phone,
        error: 'Număr de telefon invalid (lungime incorectă)',
      };
    }

    return {
      isValid: true,
      formatted: `+${cleanPhone}`,
      error: '',
    };
  },

  /**
   * Normalizează numărul pentru API
   */
  normalizePhoneForAPI(phone) {
    return phone.replace(/^\+/, '');
  },
};
