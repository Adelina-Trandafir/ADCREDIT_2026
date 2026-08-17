/**
 * 📝 FILTER FORM MIXIN
 * Gestionează state și validare formular
 *
 * RESPONSABILITĂȚI:
 * ✅ Inițializare/Distrugere combobox exact
 * ✅ Setare coloană curentă
 * ✅ Resetare/Validare formular
 * ✅ Ștergere toate filtrele
 * ✅ Populate date modal
 * ✅ Getters pentru state
 * ✅ Setters pentru state
 *
 * @version 4.0.0
 */

export const filterFormMixin = {
  /**
   * 🎯 INIȚIALIZARE EXACT COMBOBOX
   */
  async initializeExactCombobox() {
    if (!this.exactFilterContainer) {
      this.log.error('Containerul pentru combobox nu a fost găsit');
      return;
    }

    if (this.exactCombobox) return;

    this.cbxStaticData = null;

    try {
      const isReadonly = this.useReadOnlyCbx === 1;
      // Pentru readonly, încarcă datele statice ÎNAINTE de inițializare
      if (isReadonly) await this.fetchColumnValues();

      this.exactCombobox = new this.Combobox(this.comboboxElement, {
        placeholder: 'Selectați o valoare...',
        readonly: isReadonly,
        staticData: this.cbxStaticData,

        onSearch: isReadonly
          ? null
          : async (query) => {
              // Logica pentru search normal
              const filterData = this.makeFilterData('search');
              if (filterData) {
                const result = this.generateFilterSQL(filterData); // din filter-sql.js
                return await this.requestColumnValues(result);
              }
              return [];
            },

        onSelect: (value) => {
          this.cbxSelectedValue = value;
          this.log(`✅ Selectat din combobox: ${value}`);
          if (this.cbxSelectedValue) this.handleApplyBtnClick();
        },
      });

      this.exactCombobox.setEnabled(true);
      this.log(`✅ Combobox ${isReadonly ? 'readonly' : 'normal'} inițializat`);
    } catch (error) {
      this.log.error('Eroare la inițializarea combobox-ului:', error);
    }
  },

  /**
   * 📅 INIȚIALIZARE WIDGET-URI CALENDAR
   */
  async initializeCalendarWidgets() {
    if (!this.rangeFromElement || !this.rangeToElement) {
      this.log.error('Containerul pentru widget-urile calendar nu a fost găsit');
      return;
    }

    try {
      const dateConfig = {
        allowWeekends: true,
        allowPast: true,
        allowFuture: true,
        customDate: true,
        customDateTime: false,
      };

      this.calendarFrom = this.calendarManager.createCalendarForInput(
        this.rangeFromElement,
        dateConfig,
        true
      );

      this.rangeFromElement.setAttribute('data-input-type', 'date');

      this.calendarTo = this.calendarManager.createCalendarForInput(
        this.rangeToElement,
        dateConfig,
        true
      );

      this.rangeToElement.setAttribute('data-input-type', 'date');

      this.log('✅ Widget-urile calendar au fost inițializate cu succes');
    } catch (error) {
      this.log.error('Eroare la inițializarea widget-urilor calendar:', error);
    }
  },

  /**
   * 🗑️ DISTRUGE COMBOBOX EXISTENT
   */
  destroyExistingCombobox() {
    if (this.exactCombobox) {
      try {
        this.exactCombobox.destroy();
        this.log('🧹 Combobox existent distrus');
      } catch (error) {
        this.log.error('Eroare la distrugerea combobox-ului:', error);
      } finally {
        this.exactCombobox = null;
      }
    }
  },

  destroyExistingCalendars() {
    try {
      if (this.calendarFrom) {
        this.calendarFrom.destroy();
        this.calendarFrom = null;
        this.rangeFromElement.removeAttribute('data-input-type');
      }
      if (this.calendarTo) {
        this.calendarTo.destroy();
        this.calendarTo = null;
        this.rangeToElement.removeAttribute('data-input-type');
      }
    } catch (error) {
      this.log.error('Eroare la distrugerea widget-urilor calendar:', error);
    }
  },

  /*
   * 🎯 SET CURRENT COLUMN
   */
  setCurrentColumn(columnData) {
    const { id, field, PK, readOnlyCbx, type } = columnData;
    this.currentColumn = columnData;
    this.currentColumnId = id;
    this.currentColumnName = field;
    this.currentColumnPK = PK;
    this.currentColumnType = type;
    this.useReadOnlyCbx = readOnlyCbx;

    // // Update modal state
    // this.modalState.currentColumn = id;
    // this.modalState.currentField = field;
    // this.modalState.currentType = columnData.type;
    // this.modalState.currentFilterConfig = columnData.filterConfig;

    this.log(`📌 Coloană curentă setată: ${field} (ID: ${id})`);
  },

  /**
   * 🔄 RESET FORM
   */
  resetForm() {
    if (!this.injectedFilterDIV) return;

    // Resetează combobox-ul exact
    this.exactCombobox?.clear();
    this.exactCombobox?.destroy();
    this.exactCombobox = null;

    // Resetează calendar widgets
    this.destroyExistingCalendars();

    // Resetează câmpurile textuale
    if (this.partialTextElement) this.partialTextElement.value = '';
    if (this.rangeFromElement) this.rangeFromElement.value = '';
    if (this.rangeToElement) this.rangeToElement.value = '';
  },

  /**
   * 🧹 ȘTERGERE TOATE FILTRELE
   */
  clearAllFilters() {
    try {
      this.log('🧹 Ștergere toate filtrele...');

      const clearedFilters = Object.fromEntries(this.activeFilters);

      // Clear internal state
      this.activeFilters.clear();

      // Actualizează toate vizualurile
      Object.keys(clearedFilters).forEach((columnId) => {
        this.updateFilterVisual(columnId, false);
      });

      // Emit eveniment pentru refresh tabel
      this.eventBus.emit(EVENTS.DATA_REFRESH_START, {
        reason: 'all_filters_cleared',
        filterSQL: '',
        clearedFilters,
        timestamp: Date.now(),
      });

      // Tracking
      this.metrics.filtersCleared += Object.keys(clearedFilters).length;

      this.log(`🧹 ${Object.keys(clearedFilters).length} filtre șterse cu succes`);
    } catch (error) {
      this.handleError('Eroare la ștergerea tuturor filtrelor', error);
    }
  },

  /**
   * 📊 GETTERS - State
   */
  getModalState() {
    return { ...this.modalState };
  },

  getNormalState() {
    return { ...this.normalState };
  },

  getCurrentColumn() {
    return {
      id: this.currentColId,
      field: this.currentField,
      PK: this.currentPK,
      data: this.currentColumn,
    };
  },

  /**
   * 🔍 FETCH COLUMN VALUES (API call)
   */
  async fetchColumnValues() {
    try {
      if (!this.currentColumn) {
        this.log.error('Coloana curentă nu este setată pentru fetch column values');
        return;
      }

      // Construiește otherFilter (exclude filtrul curent)
      const otherFilter =
        this.activeFilters && this.activeFilters instanceof Map
          ? Array.from(this.activeFilters.values())
              .filter((v) => v && v.filterString && v.id !== this.currentFilter?.id)
              .map((v) => v.filterString)
              .join(' AND ')
          : '';

      const shouldIncludeCurrentFilter = this.currentColumn.filter !== '';

      // Construiește filtrul de bază
      const baseFilter = [
        shouldIncludeCurrentFilter ? this.currentColumn.filter : null,
        otherFilter || null,
      ]
        .filter((f) => f)
        .join(' AND ');

      let finalFilter = otherFilter || '';

      // API call
      const response = await fetch('/api/column-values', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          tab: this.getInstance('Tabs').currentTab,
          column: this.currentColumn.field,
          limit: 50,
          PK: this.currentColumn.PK,
          filtru: finalFilter,
          NumeTabel: this.currentColumn.NumeTabel,
        }),
      });

      if (!response.ok) {
        this.log.error('Eroare la fetch column values:', response.statusText);
        return;
      }

      const data = await response.json();

      if (data.length === 0) {
        this.log('⚠️ Nu s-au găsit valori pentru coloană');
        this.cbxStaticData = [];
        return;
      }

      this.cbxStaticData = (data.values || []).map((o) => ({
        value: o['0'],
        label: o['1'],
      }));
    } catch (error) {
      this.log.error('Eroare la căutarea valorilor:', error);
      this.cbxStaticData = [];
    }
  },

  /**
   * 📝 POPULARE DATE MODAL
   */
  async populateModalData(calculatedType = null) {
    let newFilter = false;

    if (this.currentFilter != this.currentColumn?.filterConfig) {
      this.currentFilter = this.currentColumn?.filterConfig;
      newFilter = true;
    }

    if (this.currentFilter) {
      const type = this.currentFilter.type;
      const value = this.currentFilter.value;
      const from = this.currentFilter.from;
      const to = this.currentFilter.to;

      // Selectează tipul de filtru
      const radio = this.optionButtons[type];

      if (radio) {
        radio.checked = true;
        this.handleAccordionChange(type);

        // Setează valorile în funcție de tip
        if (type === 'exact' && value) {
          if (newFilter) await this.populateExactFilter(this.currentFilter);
        } else if (type === 'partial' && value) {
          if (this.partialTextElement) this.partialTextElement.value = value;
        } else if (type === 'range') {
          if (this.rangeFromElement) this.rangeFromElement.value = from || '';
          if (this.rangeToElement) this.rangeToElement.value = to || '';
        }
      }
    } else {
      if (!calculatedType) {
        this.log.error('Tipul de filtru nu este specificat pentru resetare');
        return;
      }

      const type = calculatedType;

      if (type === 'exact') {
        this.exactCombobox.setValue('');
      } else if (type === 'partial') {
        if (this.partialTextElement) this.partialTextElement.value = '';
      } else if (type === 'range') {
        if (this.rangeFromElement) this.rangeFromElement.value = '';
        if (this.rangeToElement) this.rangeToElement.value = '';
      }
    }
  },

  /**
   * 🎯 POPULARE SPECIALĂ PENTRU EXACT FILTER
   */
  async populateExactFilter(existingFilter) {
    try {
      this.log(`🔍 Populez exact filter cu valoarea: ${existingFilter}`);

      if (!this.exactCombobox) {
        this.log.error('Combobox exact nu este inițializat');
        return;
      }

      const searchResults = await this.requestColumnValues(existingFilter);

      if (!searchResults || searchResults.length === 0) {
        this.log(`⚠️ Nu s-au găsit rezultate`);
        return;
      }

      const matchingItem = searchResults.find(
        (item) => String(item.value) === String(existingFilter.value)
      );

      if (matchingItem) {
        this.exactCombobox.setValue(matchingItem.label);
        this.cbxSelectedValue = matchingItem.value;
        this.log(`✅ Exact filter populat: "${matchingItem.label}"`);
      }
    } catch (error) {
      this.log.error('Eroare la popularea exact filter:', error);
      this.showError('Eroare la încărcarea valorii filtru');
    }
  },
};
