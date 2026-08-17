// File: static/js/table-controller/table-controller-this.EVENTS.js
/**
 * 🔔 TABLE CONTROLLER EVENTS MIXIN
 * Gestionează setup-ul și handling-ul evenimentelor
 *
 * RESPONSABILITĂȚI:
 * ✅ Înregistrează event listeners
 * ✅ Event handlers pentru date
 * ✅ Event handlers pentru filtre
 * ✅ Event handlers pentru UI
 * ✅ Event handlers pentru tabs
 * ✅ Event handlers pentru sistem
 *
 * @version 1.0.0
 */

export const tableControllerEventsMixin = {
  /**
   * 🔔 ÎNREGISTREAZĂ EVENT LISTENERS
   */
  setupEventListeners() {
    // EventBus listeners cu tracking automat
    this.addBusListener(this.EVENTS.DATA_LOAD_ERROR, (error) => this.handleDataError(error));

    // Filter events cu tracking
    // this.addBusListener(this.EVENTS.FILTER_APPLIED, (filterData) =>
    //   this.handleFilterApplied(filterData)
    // );
    // this.addBusListener(this.EVENTS.FILTER_CLEARED, (columnId) =>
    //   this.handleFilterCleared(columnId)
    // );

    // UI events cu tracking
    this.addBusListener(this.EVENTS.ROW_SELECTED, (rowData) => this.handleRowSelect(rowData));
    this.addBusListener(this.EVENTS.COLUMN_RESIZE, (resizeData) =>
      this.handleColumnResize(resizeData)
    );

    // Tab events cu tracking
    this.addBusListener(this.EVENTS.TAB_CLICKED_SAME, (data) => this.handleTabChanged(true, data));
    this.addBusListener(this.EVENTS.TAB_CLICKED_OTHER, (data) =>
      this.handleTabChanged(false, data)
    );

    // System events cu tracking
    this.addBusListener(this.EVENTS.ROW_SELECT_TOGGLE, (data) => this.toggleSelectMode(data));

    // Table build complete
    this.addBusListener(this.EVENTS.TABLE_BUILD_COMPLETE, (data) =>
      this.handleTableBuildComplete(data)
    );

    this.log('👂 Event listeners înregistrați cu tracking automat');
  },

  /**
   * 📑 GESTIONEAZĂ SCHIMBAREA TAB-ULUI
   */
  handleTabChanged(isSameTab, data) {
    const newView = data.data.trim();

    // Actualizează view-ul
    this.currentState.view = newView;

    if (isSameTab) {
      this.log(`TAB-ul activ ${newView} a fost apăsat!`);
    } else {
      this.log(`TAB-ul ${newView} a fost apăsat!`);
      // Pentru tab nou, solicită încărcarea datelor
      this.requestDataLoad({ view: newView });
    }
  },
};
