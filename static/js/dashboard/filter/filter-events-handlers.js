/**
 * 📡 FILTER DATA MIXIN
 * Gestionează API calls și event handling
 *
 * RESPONSABILITĂȚI:
 * ✅ Handle apply filter
 * ✅ Handle clear filter
 * ✅ Fetch column values (API)
 * ✅ Event communication cu alte module
 *
 * @version 4.0.0
 */

export const filterEventsHandlersMixin = {
  /**
   * ✅ APLICARE FILTRU CURENT
   */
  async handleApplyBtnClick() {
    if (!this.currentColumn) return;
    this.hideModalWithAnimation();

    let filterData = this.makeFilterData('selected');

    if (filterData) {
      const filterString = this.generateFilterSQL(filterData);
      filterData.filterString = filterString;

      await this.applyFilter(filterData);

      this.currentColumn.hasFilter = true;
      this.currentColumn.filter = filterString;
      this.currentColumn.filterConfig = filterData;

      this.log('✅ Filtru aplicat', { filterData });
    } else {
      this.showError('Introduceți o valoare pentru filtru');
      return;
    }
  },

  /**
   * 🗑️ ȘTERGERE FILTRU CURENT
   */
  async handleClearBtnClick() {
    try {
      this.log(`🗑️ Ștergere filtru pentru: ${this.currentColId}`);
      if (this.isVisible) this.hideModalWithAnimation();
      await this.handleClearFilter();
    } catch (error) {
      this.handleError('Eroare la ștergerea filtrului', error);
    }
  },

  /**
   * 🗑️ ȘTERGERE FILTRU
   */
  async handleClearFilter(receivedData = null) {
    // Vine direct din buton sau din eventBus
    // Daca vine din buton, foloseste currentColumn si currentFilter
    // Daca vine din eventBus, foloseste datele primite
    const startTime = performance.now();
    let columnData = null;
    let filterData = null;

    if (receivedData?.data) {
      ({ columnData, filterData } = receivedData.data);
    } else {
      columnData = this.currentColumn;
      filterData = {
        field: '',
        operator: '',
        value: '',
        type: '',
        id: columnData.id,
        filterString: '',
      };
    }

    const removedFilter = this.activeFilters.get(columnData.id);

    if (!columnData || !filterData || !removedFilter) {
      this.log.error('Date insuficiente pentru ștergerea filtrului');
      return;
    }

    try {
      this.log(`✅ Eliminare filtru de pe ${columnData.field}`);

      // Construiește otherFilters (exclude filtrul curent)
      filterData.otherFilters =
        this.activeFilters && this.activeFilters instanceof Map
          ? Array.from(this.activeFilters.values())
              .filter((v) => v && v.filterString && v.id !== columnData.id)
              .map((v) => v.filterString)
              .join(' AND ')
          : '';

      // Emit eveniment pentru refresh tabel
      this.eventBus.emit(EVENTS.DATA_REFRESH_START, {
        reason: 'filter_cleared',
        view: this.getInstance('tabs').currentView,
        sort: '',
        currentFilter: filterData.filterString,
        otherFilters: filterData.otherFilters,
        hideHidden: 1,
        columnId: columnData.id,
        timestamp: Date.now(),
      });

      // Așteaptă refresh completat
      try {
        const refreshResult = await this.eventBus.waitFor(EVENTS.DATA_REFRESH_COMPLETE);
        this.log('🔄 Refresh completat după ștergerea filtrului:', refreshResult);
      } catch (e) {
        this.log('⚠️ Timeout la așteptarea refreshului');
      }

      this.activeFilters.delete(columnData.id);

      // Salvează filtrul și în coloană
      columnData.hasFilter = false;
      columnData.filter = '';
      columnData.filterConfig = null;

      // Închide modalul
      // if (this.isVisible) this.hideModalWithAnimation();

      // Tracking performance
      const filterTime = performance.now() - startTime;
      this.updateMetrics('filter_cleared', filterTime);

      // Adaugă în istoric
      this.addToHistory({
        action: 'filter_cleared',
        column: filterData.id,
        filterConfig: removedFilter,
        executionTime: filterTime,
        timestamp: Date.now(),
      });

      this.log(`✅ Filtru șters cu succes în ${filterTime.toFixed(2)}ms`);
    } catch (error) {
      this.handleError('Eroare la stergerea filtrului', error);

      this.eventBus.emit(EVENTS.FILTER_ERROR, {
        action: 'filter_clear',
        error: error.message,
        filterData,
        timestamp: Date.now(),
      });
    }
  },

  /** HANDLER BUTON ÎNCHIDERE */
  handleCloseButtonClick(event) {
    event.stopPropagation();
    this.onPanelClosed();
    this.log('❌ Buton închidere apăsat');
    eventBus.emit(EVENTS.PANEL_HIDE_REQUEST, { panelId: this.config.panelId });
  },

  /** HANDLE STICKY BUTTON */
  handleStickyButtonClick(event) {
    event.stopPropagation();
    eventBus.emit(EVENTS.PANEL_STICKY_TOGGLE_REQUEST, this.config.panelId);
    this.log('📌 Buton sticky apăsat');
  },

  /**
   * 🎯 HANDLER CLICK PE COLOANĂ
   */
  handleRowClick(columnId, displayName) {
    this.log(`🖱️ Click pe randul: ${displayName}`);
    this.stats.rowsClicks++;
    let subPanel = null;

    const columnItem = this.columnsList.querySelector(`[data-field="${columnId}"]`);
    if (!columnItem) {
      this.handleError('Element coloană nu a fost găsit');
      return;
    }

    // Obține filter manager instance
    const filterManagerInstance = getInstance('filterManager');
    if (!filterManagerInstance) {
      this.handleError('Filter Manager nu este disponibil');
      return;
    }

    const activeFilters = filterManagerInstance.activeFilters;
    const activeColumn = Array.from(this.columnsCache.values()).find((col) => col.id === columnId);

    // Construiește obiect column data similar cu cel din table
    const filterData = {
      id: columnId,
      field: columnId,
      name: displayName,
      hasFilter: activeFilters.has(columnId),
      filter: activeFilters.get(columnId)?.filterString || null,
      filterConfig: activeFilters.get(columnId) || null,
    };

    this.hideSubPanel();

    if (this.activeElement === columnId) {
      this.activeElement = null;
    } else {
      this.activeElement = columnId;
      subPanel = this.showSubPanel(columnItem, columnId, displayName);
    }

    // Emit event pentru a deschide filter modal
    eventBus.emit(EVENTS.FILTER_SHOW_WINDOW, {
      columnData: activeColumn,
      filterData: filterData,
      subPanel: subPanel,
      source: 'filter-panel',
    });
  },

  async handleAccordionChange(selectedType) {
    for (const radio of Object.values(this.optionButtons)) {
      const isSelected = radio.value === selectedType;

      switch (radio.value) {
        case 'partial':
          this.configurePartialOption(isSelected);
          break;
        case 'range':
          if (isSelected) {
            await this.initializeCalendarWidgets();
          }
          this.configureRangeOption(isSelected);
          break;
        case 'exact':
          if (isSelected) {
            const loader = this.exactFilterContainer.querySelector('.filter-window-exact-loader');
            if (loader) loader.classList.add('filter-window-exact-loader-visible');
            await this.initializeExactCombobox();
            // Ascunde loader
            if (loader) loader.classList.remove('filter-window-exact-loader-visible');
          }
          this.configureExactOption(isSelected);
          break;
      }
    }

    // Focus pe input-ul corespunzător după schimbare
    setTimeout(() => {
      this.focusAppropriateInputForType(selectedType);
    }, 150);
  },

  /**
   * 🔍 CERERE VALORI COLOANĂ (API call prin evenimente)
   */
  async requestColumnValues(filterData) {
    return new Promise((resolve, reject) => {
      const requestId = `fetch_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

      // Setup listeners pentru răspuns
      const successHandler = (response) => {
        if (response.data.requestId === requestId) {
          this.eventBus.off(EVENTS.FILTER_FETCH_COLUMN_VALUES_SUCCESS, successHandler);
          this.eventBus.off(EVENTS.FILTER_FETCH_COLUMN_VALUES_ERROR, errorHandler);
          resolve(response.data.results);
        }
      };

      const errorHandler = (response) => {
        if (response.data.requestId === requestId) {
          this.eventBus.off(EVENTS.FILTER_FETCH_COLUMN_VALUES_SUCCESS, successHandler);
          this.eventBus.off(EVENTS.FILTER_FETCH_COLUMN_VALUES_ERROR, errorHandler);
          this.log.error('Eroare la fetch valori:', response.data.error);
          resolve([]);
        }
      };

      this.eventBus.on(EVENTS.FILTER_FETCH_COLUMN_VALUES_SUCCESS, successHandler);
      this.eventBus.on(EVENTS.FILTER_FETCH_COLUMN_VALUES_ERROR, errorHandler);

      // Emit cu structura SIMPLĂ
      this.eventBus.emit(EVENTS.FILTER_FETCH_COLUMN_VALUES, {
        filterData,
        columnData: this.currentColumn,
        requestId,
        timestamp: Date.now(),
      });

      // Timeout pentru safety
      setTimeout(() => {
        this.eventBus.off(EVENTS.FILTER_FETCH_COLUMN_VALUES_SUCCESS, successHandler);
        this.eventBus.off(EVENTS.FILTER_FETCH_COLUMN_VALUES_ERROR, errorHandler);
        resolve([]);
      }, 10000);
    });
  },
};
