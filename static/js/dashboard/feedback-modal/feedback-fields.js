export const feedbackFieldsMixin = {
  /**
   * Încarcă status-urile din server (prin data-loader-extra.js)
   */
  loadStatusData() {
    const department = this.sessionData.get('Department');
    if (!department) {
      this.log.error('⚠️ Departamentul nu este setat în sessionData');
      return;
    }
    try {
      this.log('📤 Emit cerere pentru Baza Status...');
      this.eventBus.emit(this.EVENTS.EXTRA_DATA_LOAD_START, {
        endpoint: 'get_baza_status',
        requestType: 'baza_status',
        cache: true,
        timeout: 10000,
        department: department,
      });
      this.log('✅ Cerere emisă pentru status-uri');
    } catch (error) {
      this.log.error('⌫ Eroare la emiterea cererii pentru status-uri', error);
    }
  },

  /**
   * Populează Combobox-ul de status-uri cu datele încărcate
   */
  populateStatusDropdown() {
    if (!this.statusData || this.statusData.length === 0) {
      this.log.error('⌫ Nu există status-uri încărcate!');
      return;
    }

    if (!this.statusCombobox) {
      this.log.error('⌫ Combobox nu este inițializat!');
      return;
    }

    // Populează Combobox
    this.statusCombobox.options.staticData = this.statusData.map((status) => ({
      value: status.IdStatus,
      label: status.FelStatus,
      ...status,
    }));

    this.statusCombobox.options.onSearch = async (query) => {
      const filtered = this.statusCombobox.options.staticData.filter((item) =>
        item.label.toLowerCase().includes(query.toLowerCase())
      );
      return filtered;
    };

    // 🎨 OVERRIDE renderResults pentru a adăuga culorile
    const originalRenderResults = this.statusCombobox.renderResults.bind(this.statusCombobox);

    this.statusCombobox.renderResults = (query) => {
      originalRenderResults(query);

      const options = this.statusCombobox.dropdown.querySelectorAll('.combobox-option');

      options.forEach((option) => {
        const value = option.dataset.value;
        const status = this.statusData.find((s) => s.IdStatus == value);

        if (status && status.BackColor) {
          option.style.setProperty('--status-color-left', 'white');
          option.style.setProperty('--status-color-right', status.BackColor);
        }
      });
    };

    this.log(`✅ ${this.statusData.length} status-uri populate în Combobox`);
  },

  shadeColor(color, percent) {
    let R = parseInt(color.substring(1, 3), 16);
    let G = parseInt(color.substring(3, 5), 16);
    let B = parseInt(color.substring(5, 7), 16);
    R = parseInt((R * (100 + percent)) / 100);
    G = parseInt((G * (100 + percent)) / 100);
    B = parseInt((B * (100 + percent)) / 100);
    R = R < 255 ? R : 255;
    G = G < 255 ? G : 255;
    B = B < 255 ? B : 255;
    const RR = R.toString(16).length == 1 ? '0' + R.toString(16) : R.toString(16);
    const GG = G.toString(16).length == 1 ? '0' + G.toString(16) : G.toString(16);
    const BB = B.toString(16).length == 1 ? '0' + B.toString(16) : B.toString(16);
    return '#' + RR + GG + BB;
  },

  /**
   * Handler pentru datele primite de la server (prin data-loader-extra.js)
   */
  handleExtraDataLoaded(eventData) {
    const { receivedData } = eventData.data;
    const requestType = receivedData.requestType || eventData.data.requestType;

    this.log(`🔨 Primite date pentru requestType: ${requestType}`, {
      dataSize: receivedData?.results?.length || 0,
    });

    if (!receivedData || !receivedData.success || !receivedData.results) {
      this.log.error(`⌫ Date invalide pentru requestType: ${requestType}`, receivedData);
      return;
    }

    if (requestType === 'baza_status') {
      this.statusData = receivedData.results;
      this.log(`✅ ${this.statusData.length} status-uri încărcate în memorie`);

      if (this.modalElement && this.modalElement.classList.contains('active')) {
        this.populateStatusDropdown();
      }
    }
  },

  /**
   * Inițializează Combobox pentru Status
   */
  initializeStatusCombobox() {
    const statusContainer = this.statusElement;

    if (!statusContainer) {
      this.log.error('⌫ Container pentru status combobox nu a fost găsit!');
      return;
    }

    this.statusCombobox = new this.Combobox(statusContainer, {
      placeholder: 'Selectează status...',
      readonly: true,
      staticData: [],
      onSelect: (value, text, data) => {
        this.handleStatusSelect(value, text, data);
      },
    });

    this.log('✅ Status Combobox inițializat');
  },

  /**
   * Handler pentru selectarea status-ului din Combobox
   * ✅ FIXED: Anulează operațiile anterioare
   */
  handleStatusSelect(value, text) {
    this.log(`📋 Status selectat: ${text} (${value})`);

    // ✅ Anulează operațiile anterioare în desfășurare
    if (this._pendingCalendarOperation) {
      clearTimeout(this._pendingCalendarOperation);
      this._pendingCalendarOperation = null;
    }

    if (!value) {
      this.selectedStatus = null;
      this.destroyCalendar();
      this.updateEditorHeaderAndFooter('#ffffff');
      this.setEditorEditable(true);
      return;
    }

    const statusInfo = this.statusData.find((s) => s.IdStatus == value);

    if (!statusInfo) {
      this.log.error(`⌫ Nu am găsit status cu IdStatus=${value} în statusData`);
      return;
    }

    this.selectedStatus = {
      IdStatus: value,
      FelStatus: text,
      IDSG: parseInt(statusInfo.IDSG),
      BackColor: statusInfo.BackColor,
      TipStatus: statusInfo.TipStatus,
    };

    // Schimbă culoarea de fundal
    this.updateEditorHeaderAndFooter(this.selectedStatus.BackColor);

    // ✅ Gestionează calendarul în funcție de IDSG
    if (this.selectedStatus.IDSG === 2) {
      // Determină dacă trebuie afișat și timpul
      const showTime = this.selectedStatus.IdStatus === '10';
      this.createAndShowCalendar(showTime);
    } else if (this.selectedStatus.IDSG === 3) {
      this.destroyCalendar();
      this.feedbackElement.contentEditable = 'true';
      this.feedbackElement.focus();
    } else {
      this.destroyCalendar();
    }

    this.validateForm();
  },

  /**
   * ✅ NOUĂ: Creează și afișează calendarul
   */
  createAndShowCalendar(showTime = false) {
    this.log(`📅 Creez calendar (showTime: ${showTime})`);

    // Distruge calendarul existent dacă există
    this.destroyCalendar();

    // Configurația pentru calendar
    const dateConfig = {
      defaultTime: '09:00',
      timeStep: 15,
      minTime: '07:00',
      maxTime: '20:00',
      allowPast: false,
      customDate: !showTime,
      customDateTime: showTime,
      allowWeekends: false,
    };

    // Creează calendar nou
    const fieldConfig = this.calendarManager.addFieldConfiguration('DataRecontactare', dateConfig);

    this.calendarManager.createCalendarForInput(this.calendarElement, fieldConfig, true);

    // Afișează containerul
    if (this.calendarContainerElement) {
      this.calendarContainerElement.style.display = 'block';
    }

    // Setup listener pentru selecție
    this.setupDateFieldListener();

    // Deschide calendarul automat
    this._pendingCalendarOperation = setTimeout(() => {
      const calendar = this.calendarManager.calendars.get(this.calendarElement.id);
      if (calendar) {
        calendar.show();
        this.log('✅ Calendar deschis automat');
      }
    }, 100);
  },

  /**
   * ✅ NOUĂ: Distruge complet calendarul
   */
  destroyCalendar() {
    this.log('🗑️ Distrug calendar complet');

    // Anulează operații în curs
    if (this._pendingCalendarOperation) {
      clearTimeout(this._pendingCalendarOperation);
      this._pendingCalendarOperation = null;
    }

    // Curăță listenerii
    this.clearDateFieldListeners();

    // Distruge calendarul din CalendarManager
    if (this.calendarElement && this.calendarManager.calendars.has(this.calendarElement.id)) {
      try {
        this.calendarManager.removeCalendarForInput(this.calendarElement);
        this.log('✅ Calendar șters din CalendarManager');
      } catch (error) {
        this.log.error('⚠️ Eroare la ștergerea calendarului:', error);
      }
    }

    // Resetează valoarea inputului
    if (this.calendarElement) {
      this.calendarElement.value = '';
    }

    // Ascunde containerul
    if (this.calendarContainerElement) {
      this.calendarContainerElement.style.display = 'none';
    }

    this.log('✅ Calendar distrus complet');
  },

  /**
   * ✅ FIXED: Setup listener cu verificare defensivă
   */
  setupDateFieldListener() {
    if (!this.calendarElement) {
      this.log.error('⌫ Input pentru dată nu există');
      return;
    }

    // Curăță listenerii anteriori
    this.clearDateFieldListeners();

    // Adaugă listener nou
    this._dateSelectedUnsubscribe = this.addBusListener(EVENTS.CALENDAR_DATE_SELECTED, (data) => {
      // ✅ Verificare defensivă
      const calendar = this.calendarManager.calendars.get(this.calendarElement.id);

      if (!calendar) {
        this.log.error('⌫ Calendar nu mai există în manager');
        return;
      }

      if (
        data.data.fieldName === 'DataRecontactare' &&
        data.data.instanceId === calendar.instanceId
      ) {
        this.log('📅 Data selectată, activez editorul');
        this.feedbackElement.contentEditable = 'true';
        this.feedbackElement.focus();
      }
    });

    this.log('✅ Date field listener configurat');
  },

  /**
   * ✅ FIXED: Curăță listenerii pentru câmpul de dată
   */
  clearDateFieldListeners() {
    if (this._dateSelectedUnsubscribe) {
      this._dateSelectedUnsubscribe();
      this._dateSelectedUnsubscribe = null;
      this.log('✅ Date field listeners curățați');
    }
  },

  /**
   * Obține status-ul selectat curent
   */
  getSelectedStatus() {
    if (!this.selectedStatus) {
      this.log('⚠️ Niciun status selectat');
      return null;
    }

    this.log(
      `✅ Status selectat: ${this.selectedStatus.FelStatus} (ID: ${this.selectedStatus.IdStatus})`
    );

    return {
      IdStatus: this.selectedStatus.IdStatus,
      FelStatus: this.selectedStatus.FelStatus,
      IDSG: this.selectedStatus.IDSG,
      BackColor: this.selectedStatus.BackColor,
      TipStatus: this.selectedStatus.TipStatus,
    };
  },

  /**
   * ✅ FIXED: Obține data selectată cu verificare
   */
  getSelectedDate() {
    if (!this.selectedStatus || this.selectedStatus.IDSG !== 2) {
      this.log('⚠️ Calendarul nu e activ pentru acest status');
      return null;
    }

    if (!this.calendarElement) {
      this.log.error('⌫ Calendar element nu există');
      return null;
    }

    // ✅ Verifică dacă calendarul există în CalendarManager
    if (!this.calendarManager.calendars.has(this.calendarElement.id)) {
      this.log.error('⌫ Calendar nu există în CalendarManager');
      return null;
    }

    const dateValue = this.calendarElement.value.trim();

    if (!dateValue) {
      this.log('⚠️ Nicio dată selectată în calendar');
      return null;
    }

    this.log(`📅 Dată selectată: ${dateValue}`);
    return dateValue;
  },

  /**
   * ✅ FIXED: Resetează toate câmpurile
   */
  clearFields() {
    this.log('🧹 Curăț toate câmpurile...');

    // Reset status combobox
    if (this.statusCombobox) {
      this.statusCombobox.clear();
      this.log('✅ Status combobox curățat');
    }

    // Reset selectedStatus
    this.selectedStatus = null;

    // Distruge calendarul complet
    this.destroyCalendar();

    // Reset culoarea la alb
    this.headerElement.classList.remove('with-status');
    this.footerElement.classList.remove('with-status');

    this.log('✅ Toate câmpurile au fost resetate');
  },
};
