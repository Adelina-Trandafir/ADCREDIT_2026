// js/components/dashboard/add-lead-modal/add-lead-fields.js
/**
 * 🌍 ADD LEAD FIELDS MIXIN
 * Gestionează combobox țări și input telefon
 * ✨ UPDATE: Integrare cu phone formatter pentru input mask
 *
 * @version 2.0.0
 */

export const addLeadFieldsMixin = {
  /**
   * Lista țărilor UE cu flags și dial codes
   */
  euCountries: [
    { code: 'RO', dialCode: '+40', flag: 'ro', name: 'România' },
    { code: 'AT', dialCode: '+43', flag: 'at', name: 'Austria' },
    { code: 'BE', dialCode: '+32', flag: 'be', name: 'Belgia' },
    { code: 'BG', dialCode: '+359', flag: 'bg', name: 'Bulgaria' },
    { code: 'HR', dialCode: '+385', flag: 'hr', name: 'Croația' },
    { code: 'CY', dialCode: '+357', flag: 'cy', name: 'Cipru' },
    { code: 'CZ', dialCode: '+420', flag: 'cz', name: 'Cehia' },
    { code: 'DK', dialCode: '+45', flag: 'dk', name: 'Danemarca' },
    { code: 'EE', dialCode: '+372', flag: 'ee', name: 'Estonia' },
    { code: 'FI', dialCode: '+358', flag: 'fi', name: 'Finlanda' },
    { code: 'FR', dialCode: '+33', flag: 'fr', name: 'Franța' },
    { code: 'DE', dialCode: '+49', flag: 'de', name: 'Germania' },
    { code: 'GR', dialCode: '+30', flag: 'gr', name: 'Grecia' },
    { code: 'HU', dialCode: '+36', flag: 'hu', name: 'Ungaria' },
    { code: 'IE', dialCode: '+353', flag: 'ie', name: 'Irlanda' },
    { code: 'IT', dialCode: '+39', flag: 'it', name: 'Italia' },
    { code: 'LV', dialCode: '+371', flag: 'lv', name: 'Letonia' },
    { code: 'LT', dialCode: '+370', flag: 'lt', name: 'Lituania' },
    { code: 'LU', dialCode: '+352', flag: 'lu', name: 'Luxemburg' },
    { code: 'MT', dialCode: '+356', flag: 'mt', name: 'Malta' },
    { code: 'NL', dialCode: '+31', flag: 'nl', name: 'Olanda' },
    { code: 'PL', dialCode: '+48', flag: 'pl', name: 'Polonia' },
    { code: 'PT', dialCode: '+351', flag: 'pt', name: 'Portugalia' },
    { code: 'SK', dialCode: '+421', flag: 'sk', name: 'Slovacia' },
    { code: 'SI', dialCode: '+386', flag: 'si', name: 'Slovenia' },
    { code: 'ES', dialCode: '+34', flag: 'es', name: 'Spania' },
    { code: 'SE', dialCode: '+46', flag: 'se', name: 'Suedia' },
  ],

  /**
   * ✨ Inițializează combobox pentru țări CU PREFIX ICON
   */
  initializeCountryCombobox() {
    if (!this.countryContainerElement) {
      this.log.error('❌ Container pentru țări nu a fost găsit!');
      return;
    }

    // Pregătește datele pentru dropdown (cu HTML pentru steaguri)
    const countryData = this.euCountries.map((country) => ({
      value: country.code,
      label: `<span class="fi fi-${country.flag} country-flag"></span> ${country.name}`,
      data: country,
    }));

    // ✨ Creează combobox CU PREFIX ICON
    this.countryCombobox = new this.Combobox(this.countryContainerElement, {
      placeholder: 'Selectează țara...',
      readonly: true,
      staticData: countryData,
      allowHtml: true,
      prefixIcon: true,
      showOnlyIcon: true,
      onSelect: (value, text, data) => {
        // ✨ Folosește versiunea cu mask
        this.handleCountrySelectWithMask(value, text, data);
      },
    });

    // ✨ Setează România ca valoare implicită
    const romaniaData = this.euCountries.find((c) => c.code === 'RO');

    // Setează textul în input (doar numele țării)
    this.countryCombobox.setValue('RO', romaniaData.name);

    // ✨ Setează steagul în prefix icon
    this.countryCombobox.setPrefixIcon(`<span class="fi fi-ro"></span>`);

    // ✨ IMPORTANT: Inițializează input mask DUPĂ combobox
    this.initializePhoneInputMask();

    this.log('✅ Country combobox inițializat cu România + phone mask');
  },

  handlePhoneSubmit() {
    // Obține numărul formatat
    const phone = this.getFormattedPhone();

    if (!phone) {
      this.log('⚠️ Telefon gol, nu fac submit');
      return;
    }

    // Verifică dacă e complet (lungime min/max)
    if (!this.isPhoneComplete()) {
      this.showPhoneError('Numărul de telefon este incomplet');
      return;
    }

    // ✅ Validare finală cu libphonenumber înainte de submit
    const countryCode = this.selectedCountry.code;
    const validation = this.validateInternationalPhone(phone, countryCode);

    if (!validation.isValid) {
      this.showPhoneError(validation.error);
      return;
    }

    this.log(`📞 Submit telefon VALID către SERVER: ${validation.formatted}`);

    // Salvează numărul formatat
    this.currentPhone = validation.formatted;

    // ✅ AICI SE FACE REQUEST CĂTRE SERVER
    this.requestPhoneVerification(validation.formatted);
  },

  /**
   * ✨ Validare simplificată - numărul e deja formatat
   */
  validatePhoneInput() {
    const phone = this.getFormattedPhone();

    if (!phone) {
      this.clearPhoneError();
      this.setButtonState('ok', false);
      return;
    }

    // Verifică dacă e complet
    if (this.isPhoneComplete()) {
      this.clearPhoneError();
      this.currentPhone = phone;

      // ✅ AUTO-SUBMIT când numărul e complet
      this.handlePhoneSubmit();
    } else {
      // Nu afișa eroare până nu termină de tastat
      this.clearPhoneError();
      this.setButtonState('ok', false);
    }
  },

  /**
   * Afișează eroare telefon
   */
  showPhoneError(message) {
    this.phoneInputElement.style.borderColor = '#dc2626';
    this.phoneInputElement.title = message;
    this.log(`❌ Eroare telefon: ${message}`);
  },

  /**
   * Curăță eroare telefon
   */
  clearPhoneError() {
    this.phoneInputElement.style.borderColor = '';
    this.phoneInputElement.title = '';
  },
};
