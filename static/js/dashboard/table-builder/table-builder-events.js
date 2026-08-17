// File: static/js/table-builder/table-builder-events.js
/**
 * 🔔 TABLE BUILDER EVENTS MIXIN
 * Gestionează toate event listeners și handlers
 *
 * RESPONSABILITĂȚI:
 * ✅ Setup this.eventBus listeners
 * ✅ Column click/hover handlers
 * ✅ Filter icon handlers
 * ✅ Resize events
 * ✅ Data refresh events
 *
 * @version 1.0.0
 */

export const tableBuilderEventsMixin = {
  /**
   * 🔔 SETUP EVENT LISTENERS
   */
  setupEventListeners() {
    // 🎯 this.eventBus LISTENERS CU TRACKING AUTOMAT
    this.addBusListener(this.EVENTS.TABLE_RESIZE, (data) => this.onTableResize(data));
    this.addBusListener(this.EVENTS.SORT_CHANGED, (data) => this.onColumnSortChanged(data));
    this.addBusListener(this.EVENTS.TABLE_MANAGER_READY, (data) => this.onTableManagerReady(data));

    this.addBusListener(this.EVENTS.DATA_REFRESH_START, () =>
      this.showTableLoading('Se actualizează datele...')
    );
    this.addBusListener(this.EVENTS.DATA_REFRESH_COMPLETE, (data) =>
      this.onDataRefreshComplete(data)
    );

    // Listener pentru toggle select mode
    this.addBusListener(this.EVENTS.ROW_SELECT_TOGGLE, (data) => this.toggleSelectMode(data));

    this.log('👂 Event listeners înregistrați cu tracking automat');
  },

  /**
   * 🔄 ON TABLE RESIZE
   */
  onTableResize(resizeData = null) {
    this.log('🔄 Table resize solicitat', resizeData);
    this.rebuildTable(resizeData?.data.panelOverhead);
  },

  /**
   * ✅ ON TABLE MANAGER READY
   */
  onTableManagerReady() {
    this.hideTableLoading();
    this.buildTable();
  },

  /**
   * 🔄 ON DATA REFRESH COMPLETE
   */
  onDataRefreshComplete(Data) {
    this.rows.clear();
    this.hideTableLoading();

    const column = this.columns.get(Data?.data?.columnId);
    const newRowsData = Data?.data?.newRowsData || [];

    if (!column || !newRowsData) {
      this.log.error('❌ Coloana sau datele noi lipsesc');
      return;
    }

    // Update column filter status
    if (Data.data.reason.startsWith('filter_applied')) {
      if (column) column.hasFilter = true;
    } else if (Data.data.reason.startsWith('filter_cleared')) {
      if (column) column.hasFilter = false;
    } else {
      this.log.error('❌ Motiv incorect pentru onDataRefreshComplete', Data.data.reason);
      this.showEmptyTable();
      return;
    }

    if (column) this.updateColumnVisual(column);
    this.createRowObjects(newRowsData);
    this.buildTableRows();
    this.buildTableFooter();
  },

  /**
   * 🖱️ HANDLE COLUMN CLICK
   */
  handleColumnClick(event, column, index, headerElement) {
    event.stopPropagation();

    //if (this.getInstance('filterManager').isVisible) return;

    const filterIcon = event.target.closest('.filter-open-icon');
    if (filterIcon) {
      this.handleFilterIconClick(event, column, headerElement);
      return;
    }

    column.registerClick();

    const columnInfo = {
      columnIndex: index,
      columnId: column.id,
      columnField: column.field,
      columnName: column.header,
      columnType: column.type,
      columnWidth: column.width,
      column: column,
      clickPosition: {
        x: event.clientX,
        y: event.clientY,
      },
      timestamp: Date.now(),
    };

    this.log(`🖱️ Click pe coloana: ${column.header} (index: ${index})`);
  },

  /**
   * 🔍 HANDLE FILTER ICON CLICK
   */
  handleFilterIconClick(event, column, headerElement) {
    const expectedId = `filter-icon-${column.id}`;
    if (event.target.id !== expectedId) {
      console.warn('⚠️ ID mismatch în filter icon click');
      return;
    }
    event.stopPropagation();

    this.eventBus.emit(this.EVENTS.FILTER_SHOW_WINDOW, {
      column: column,
      headerElement: headerElement,
      source: 'table',
      timestamp: Date.now(),
    });
  },

  /**
   * 🖱️ HANDLE COLUMN MOUSE MOVE
   */
  handleColumnMouseMove(event, column, index, headerElement) {
    if (this.getInstance('filterPanelManager').isVisible) return;

    if (column.id === this.lastColumnHoveredID) return;

    this.lastColumnHoveredID = column.id;

    const columnInfo = {
      columnIndex: index,
      columnId: column.id,
      columnField: column.field,
      columnName: column.header,
      column: column,
      mousePosition: {
        x: event.clientX,
        y: event.clientY,
        offsetX: event.offsetX,
        offsetY: event.offsetY,
      },
      elementBounds: headerElement.getBoundingClientRect(),
      timestamp: Date.now(),
    };
  },

  /**
   * 🎭 HANDLE COLUMN MOUSE ENTER
   */
  handleColumnMouseEnter(event, column, index, headerElement) {
    column.setHovered(true);

    const filterIcon = document.getElementById(`filter-icon-${column.id}`);
    if (filterIcon) {
      filterIcon.style.visibility = 'visible';
      filterIcon.style.opacity = '1';
      filterIcon.style.transition = 'all 0.2s ease';
    }

    this.log(`🎭 MouseEnter pe coloana: ${column.header}`);
  },

  /**
   * 🎪 HANDLE COLUMN MOUSE LEAVE
   */
  handleColumnMouseLeave(event, column, index, headerElement) {
    column.setHovered(false);

    const filterIcon = headerElement.querySelector('.filter-open-icon');
    if (filterIcon) {
      filterIcon.style.visibility = 'hidden';
      filterIcon.style.opacity = '0.7';
      filterIcon.style.transform = 'scale(1)';
    }

    this.lastColumnHoveredID = null;

    this.log(`🎪 MouseLeave pe coloana: ${column.header}`);
  },

  handleClearFilterClick(event, column) {
    event.stopPropagation();

    this.log(`🖱️ Click pe filter-status-icon pentru coloana: ${column.header}`);

    const filterData = {
      field: '',
      operator: '',
      value: '',
      type: '',
      id: column.id,
      filterString: '',
    };

    this.eventBus.emit(this.EVENTS.FILTER_CLEAR, {
      columnId: column.id,
      columnData: column,
      filterData: filterData,
      timestamp: Date.now(),
    });
  },

  /**
   * 🔄 FILTER CHANGED
   */
  FilterChanged(column) {
    this.buildTableRows();
    if (column) this.updateColumnVisual(column);
    this.buildTableFooter();
  },

  /**
   * 🔧 SYNC COLUMNS FROM GLOBAL STATE
   */
  syncColumnsFromGlobalState() {
    this.columns.forEach((column) => column.syncFromGlobalState());
  },
};
