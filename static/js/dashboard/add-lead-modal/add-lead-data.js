// js/components/dashboard/add-lead-modal/add-lead-data.js
/**
 * 📡 ADD LEAD DATA MIXIN
 * Gestionează comunicarea cu API-ul prin EventBus
 *
 * @version 1.0.0
 */

export const addLeadDataMixin = {
  /**
   * Emit cerere verificare telefon către server
   * @param {string} phone - Număr de telefon formatat
   */
  requestPhoneVerification(phone) {
    let adjustedPhone = '';

    this.log(`📤 Cer verificare telefon: ${phone}`);

    // Arată loading spinner
    if (this.loadingElement) {
      this.loadingElement.classList.remove('hidden');
    }

    // Obține IdConsultant din sesiune
    const IdConsultant = this.sessionData.get('IdConsultant');
    const department = this.sessionData.get('Department');

    if (!IdConsultant || !department) {
      this.log.error('❌ IdConsultant sau Department nu sunt setate în sessionData');
      this.renderTableError('Eroare: ID consultant sau Department lipsă');
      return;
    }

    // Daca telefonul incepe cu +40 si this.selectedCountry.code este RO, elimina +4
    if (phone.startsWith('+40') && this.selectedCountry.code === 'RO') {
      adjustedPhone = phone.replace('+4', '');
      this.log('🔄 Telefon ajustat pentru RO, nou: ' + adjustedPhone);
    }

    // Emit eveniment prin EventBus
    this.eventBus.emit(this.EVENTS.EXTRA_DATA_LOAD_START, {
      endpoint: 'verifica_telefon',
      requestType: 'VerificaTelefon',
      cache: false,
      timeout: 10000,
      telefon: adjustedPhone || phone,
      IdConsultant: IdConsultant,
      department: department,
    });

    this.log('✅ Cerere verificare telefon emisă');
  },

  /**
   * Handler pentru răspunsul de la server
   */
  handleExtraDataLoaded(eventData) {
    const { receivedData } = eventData.data;

    const requestType = receivedData.requestType || eventData.data.requestType;

    // Procesează doar răspunsuri pentru VerificaTelefon
    if (requestType !== 'VerificaTelefon') {
      return;
    }

    if (!receivedData || !receivedData.success) {
      this.log.error('❌ Date invalide pentru VerificaTelefon', receivedData);
      this.renderTableError('Eroare la verificarea telefonului');
      return;
    }

    const foundRowsCount = receivedData.results.records?.length || 0;

    // Ascunde loading spinner
    if (this.loadingElement) {
      this.loadingElement.classList.add('hidden');
    }

    this.log(`🔨 Primite date pentru requestType: ${requestType}`, foundRowsCount);

    if (foundRowsCount === 0) {
      this.log('✅ Telefon nou, nu există în bază');
      eventBus.emit('adauga-lead-init', { telefon: this.currentPhone, tipAdaugare: 'leadNou' });
      this.closeModal();
      return;
    }
    // Procesează rezultatele
    this.processPhoneVerificationResults(receivedData.results);
  },

  /**
   * Procesează rezultatele verificării telefonului
   * @param {Array} results - Rezultate de la server
   */
  processPhoneVerificationResults(results) {
    if (!results || results.length === 0) {
      this.log('✅ Telefon nou, nu există în bază');

      // Ascunde tabelul
      this.hideTableSection();

      // Setează actionType pe 'new'
      this.actionType = 'new';

      // Activează butonul OK
      this.setButtonState('ok', true);

      this.log('✅ Buton OK activat pentru lead NOU');
      return;
    }

    this.log(`📊 Telefon găsit în bază: ${results.records.length} înregistrări`);

    // Verifică dacă există rânduri neutilizabile
    const hasUnusable = results.records?.some((row) => row.Util === 'NU');

    if (hasUnusable) {
      this.log('⚠️ Există rânduri cu Util=NU, OK dezactivat');
    }

    // Renderizează tabelul
    this.renderTable(results);

    // Dezactivează OK până când utilizatorul face o acțiune
    this.setButtonState('ok', false);

    this.log('✅ Rezultate verificare procesate');
  },

  /**
   * Verifică dacă toate rândurile sunt utilizabile
   * @param {Array} data - Date tabel
   * @returns {boolean} True dacă toate sunt utilizabile
   */
  areAllRowsUsable(data) {
    if (!data || data.length === 0) return true;

    return data.every((row) => row.Util === 'DA');
  },

  /**
   * Obține datele pentru evenimentul final
   * @returns {Object} Date pentru eveniment
   */
  getEventData() {
    const eventData = {
      telefon: this.currentPhone,
      tara: this.selectedCountry.code,
      codTara: this.selectedCountry.dialCode,
      tipAdaugare: this.actionType,
      timestamp: Date.now(),
    };

    // Pentru 'old_old', adaugă date client
    if (this.actionType === 'old_old' && this.selectedRow) {
      eventData.clientData = {
        IdClient: this.selectedRow.IdClient,
        NumeClient: this.selectedRow.NumeClient,
        CNPClient: this.selectedRow.CNPClient,
        IdJudet: this.selectedRow.IdJudet,
        Judet: this.selectedRow.Judet,
        Tara: this.selectedRow.Tara,
        DataNastere: this.selectedRow.DataNastere,
      };

      this.log('📦 Date client adăugate pentru old_old', eventData.clientData);
    }

    return eventData;
  },

  /**
   * Validează starea înainte de confirmare
   * @returns {Object} { isValid: boolean, error: string }
   */
  validateBeforeConfirm() {
    if (!this.currentPhone) {
      return {
        isValid: false,
        error: 'Număr de telefon lipsă',
      };
    }

    if (!this.actionType) {
      return {
        isValid: false,
        error: 'Nu s-a selectat nicio acțiune',
      };
    }

    if (this.actionType === 'old_old' && !this.selectedRow) {
      return {
        isValid: false,
        error: 'Nu s-a selectat niciun rând pentru folosire lead vechi',
      };
    }

    return {
      isValid: true,
      error: '',
    };
  },
};
