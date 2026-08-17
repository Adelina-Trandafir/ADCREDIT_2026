// File: static/js/table-controller/table-controller-state.js
/**
 * 📊 TABLE CONTROLLER STATE MIXIN
 * Gestionează starea aplicației
 *
 * RESPONSABILITĂȚI:
 * ✅ Menține starea curentă (view, filters, sort, selection)
 * ✅ Sincronizare cu global state
 * ✅ Update și reset state
 * ✅ Selection management
 * ✅ Filter și sort state
 *
 * @version 1.0.0
 */

export const tableControllerStateMixin = {
  /**
   * 📊 SETEAZĂ STAREA
   */
  setState(newState) {
    if (newState.view) {
      this.currentState.view = newState.view;
    }

    if (newState.filters) {
      this.currentState.filters = { ...newState.filters };
      window.activeFilters = { ...newState.filters };
    }

    if (newState.sort) {
      this.currentState.sort = { ...newState.sort };
      window.currentSort = { ...newState.sort };
    }

    this.log('📝 Stare actualizată', this.getState());
  },

  /**
   * 🔄 RESETEAZĂ STAREA
   */
  resetState() {
    this.currentState = {
      view: null,
      filters: {},
      sort: null,
      selectedRows: new Set(),
      multiSelectMode: false,
    };

    // Clear global state
    window.activeFilters = {};
    window.selectedRows = new Set();
    window.multiSelectMode = false;
    window.currentSort = null;

    this.log('🔄 Stare resetată');
  },

  /**
   * 🔄 SINCRONIZEAZĂ STAREA LOCALĂ CU CEA GLOBALĂ
   */
  syncGlobalState() {
    this.currentState.view = this.getInstance('tabs').currentView;
    this.currentState.filters = { ...this.getInstance('filterManager').activeFilters };
    this.currentState.selectedRows = new Set(this.getInstance('tableManager').selectedRows);
    this.currentState.multiSelectMode = this.getInstance('tableManager').multiSelectMode;

    if (this.getInstance('tableManager').currentSort) {
      this.currentState.sort = { ...this.getInstance('tableManager').currentSort };
    }

    this.log('🔄 Stare sincronizată cu global state');
  },

  /**
   * 🎯 GESTIONEAZĂ SELECȚIA RÂNDURILOR
   */
  handleRowSelect(eventData) {
    const { rowId, isSelected, multiSelect } = eventData.data;

    this.log('📌 Selecție rând', { rowId, isSelected, multiSelect });

    if (isSelected) {
      this.currentState.selectedRows.add(rowId);
      window.selectedRows.add(rowId);
    } else {
      this.currentState.selectedRows.delete(rowId);
      window.selectedRows.delete(rowId);
    }

    this.eventBus.emit(this.EVENTS.STATE_CHANGED, {
      type: 'selection',
      selectedRows: Array.from(this.currentState.selectedRows),
    });
  },

  /**
   * 🧹 CURĂȚĂ TOATE SELECȚIILE
   */
  clearSelections() {
    this.currentState.selectedRows.clear();
    window.selectedRows.clear();

    this.log('🧹 Selecții curățate');
  },

  /**
   * 📝 GESTIONEAZĂ FILTRELE
   */
  handleFilterApplied(eventData) {
    const { columnId, filterData } = eventData.data;

    this.log('🔍 Aplicare filtru', { columnId, filterData });

    // Actualizează starea filtrelor
    this.currentState.filters[columnId] = filterData;

    this.eventBus.emit(this.EVENTS.STATE_CHANGED, {
      type: 'filters',
      filters: this.currentState.filters,
    });
  },

  /**
   * 🧹 GESTIONEAZĂ ȘTERGEREA FILTRULUI
   */
  handleFilterCleared(eventData) {
    const { columnId } = eventData;

    this.log('🧹 Ștergere filtru', { columnId });

    // Șterge filtrul din stare
    delete this.currentState.filters[columnId];

    this.eventBus.emit(this.EVENTS.STATE_CHANGED, {
      type: 'filters',
      filters: this.currentState.filters,
    });
  },

  /**
   * 🔄 GESTIONEAZĂ SCHIMBAREA FILTRELOR
   */
  handleFiltersChanged() {
    this.log('🔄 Filtre schimbate');

    // Sincronizează starea filtrelor
    this.currentState.filters = { ...window.activeFilters };

    this.eventBus.emit(this.EVENTS.STATE_CHANGED, {
      type: 'filters',
      filters: this.currentState.filters,
    });
  },

  /**
   * 🔄 TOGGLE MOD SELECȚIE MULTIPLĂ
   */
  toggleSelectMode(data) {
    this.currentState.multiSelectMode = data.data.isActive;
    window.multiSelectMode = data.data.isActive;

    this.log('🔄 Mod selecție multiplă:', this.currentState.multiSelectMode);

    this.eventBus.emit(this.EVENTS.STATE_CHANGED, {
      type: 'selectMode',
      multiSelectMode: this.currentState.multiSelectMode,
    });
  },

  /**
   * 📏 GESTIONEAZĂ REDIMENSIONAREA COLOANELOR
   */
  handleColumnResize(eventData) {
    const { columnId, newWidth } = eventData.data;

    this.log('📏 Redimensionare coloană', { columnId, newWidth });

    if (window.columnWidths) {
      window.columnWidths[columnId] = newWidth;
    }

    this.eventBus.emit(this.EVENTS.COLUMN_RESIZED, {
      columnId,
      newWidth,
      timestamp: Date.now(),
    });
  },
};
