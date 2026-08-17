// File: static/js/table-builder/table-builder-selector.js
/**
 * 🎯 TABLE BUILDER SELECTOR MIXIN
 * Gestionează record selector (single/multi select)
 *
 * RESPONSABILITĂȚI:
 * ✅ Setup event handlers pentru selector
 * ✅ Single select mode (Access-style)
 * ✅ Multi select mode (checkbox)
 * ✅ Select all functionality
 * ✅ Visual selection states
 * ✅ Row click/double-click handling
 *
 * @version 1.0.0
 */

export const tableBuilderSelectorMixin = {
  /**
   * 🎯 SETUP RECORD SELECTOR EVENTS
   */
  setupRecordSelectorEvents() {
    // Select All checkbox handler
    const selectAllCheckbox = document.getElementById('selectAllCheckbox');
    if (selectAllCheckbox && window.multiSelectMode) {
      this.addDOMListener(selectAllCheckbox, 'change', (event) => {
        this.handleSelectAllChange(event.target.checked);
      });
    }

    // Record selector click handlers (delegation pentru performance)
    const tbody = document.getElementById('tableBody');
    if (tbody) {
      this.addDOMListener(tbody, 'click', (event) => this.handleRowClick(event));
      this.addDOMListener(tbody, 'dblclick', (event) => this.handleRowDoubleClick(event));

      // Special handling pentru checkbox-uri în record selector
      this.addDOMListener(tbody, 'change', (event) => {
        if (event.target.classList.contains('record-checkbox')) {
          const row = event.target.closest('tr');
          const rowIndex = parseInt(row.dataset.rowIndex);
          this.updateRowSelection(row, rowIndex, event.target.checked);
        }
      });
    }

    this.log('✅ Record selector events configurate');
  },

  /**
   * 🖱️ HANDLE SELECT ALL CHANGE
   */
  handleSelectAllChange(selectAll) {
    if (!window.multiSelectMode) return;

    const rows = document.querySelectorAll('#tableBody tr');

    rows.forEach((row) => {
      const rowIndex = parseInt(row.dataset.rowIndex);
      const checkbox = row.querySelector('.record-checkbox, .row-checkbox');

      if (checkbox) {
        checkbox.checked = selectAll;
        this.updateRowSelection(row, rowIndex, selectAll);
      }
    });

    // Emit event
    this.eventBus.emit(
      selectAll ? this.EVENTS.ROWS_MULTI_SELECTED : this.EVENTS.SELECTION_CLEARED,
      {
        selectedCount: selectAll ? rows.length : 0,
        action: selectAll ? 'select-all' : 'deselect-all',
        timestamp: Date.now(),
      }
    );

    this.log(`📋 Select All: ${selectAll ? 'Selectate' : 'Deselectate'} ${rows.length} rânduri`);
  },

  /**
   * 🖱️ HANDLE ROW CLICK
   */
  handleRowClick(event) {
    event.preventDefault();
    event.stopPropagation();

    let row = event.target.closest('tr');
    if (!row) return;

    // Găsește row-action-buttons pentru acest rând specific
    const actionButtons = row.querySelector('.row-action-buttons');

    // Verifică dacă butoanele sunt vizibile
    if (actionButtons) {
      if (
        actionButtons.style.visibility === 'visible' ||
        getComputedStyle(actionButtons).visibility === 'visible'
      ) {
        return; // Prioritizează butoanele
      }
    }

    const rowIndex = parseInt(row.dataset.rowIndex);
    const multiSelectMode = this.getInstance('tableController').currentState.multiSelectMode;

    if (multiSelectMode) {
      // Modul multiselect - toggle checkbox
      const checkbox = row.querySelector('.record-checkbox, .row-checkbox');
      if (checkbox) {
        checkbox.checked = !checkbox.checked;
        this.updateRowSelection(row, rowIndex, checkbox.checked);

        if (checkbox.checked) {
          this.eventBus.emit(this.EVENTS.ROW_DESELECTED, {
            rowId: row.dataset.rowId,
            rowElement: row,
            source: 'table',
          });
        } else {
          this.eventBus.emit(this.EVENTS.ROW_SELECTED, {
            rowId: row.dataset.rowId,
            rowElement: row,
            source: 'table',
          });
        }
      }
    } else {
      // Single select mode
      // Remove selection from all rows
      document.querySelectorAll('tr.clicked').forEach((r) => {
        r.classList.remove('clicked');
        const indicator = r.querySelector('.record-indicator');
        if (indicator) {
          indicator.style.background = 'transparent';
          indicator.style.borderColor = 'transparent';
        }
      });

      // Add selection to current row
      row.classList.add('clicked');
      const indicator = row.querySelector('.record-indicator');
      if (indicator) {
        indicator.style.background = '#007bff';
        indicator.style.borderColor = '#0056b3';
      }

      // Emit selection event
      this.eventBus.emit(this.EVENTS.ROW_CLICKED, {
        rowAction: 'select',
        rowIndex,
        rowElement: row,
        rowId: row.dataset.rowId,
        timestamp: Date.now(),
      });
    }
  },

  /**
   * 🖱️🖱️ HANDLE ROW DOUBLE CLICK
   */
  handleRowDoubleClick(event) {
    event.stopPropagation();
    event.preventDefault();

    const target = event.target;
    const row = target.closest('tr');

    if (!row || !row.dataset.rowId) return;

    const rowIndex = parseInt(row.dataset.rowIndex);
    const rowId = row.dataset.rowId;

    // Emite evenimentul pentru double click
    this.eventBus.emit(this.EVENTS.ROW_DOUBLE_CLICKED, {
      rowIndex,
      rowElement: row,
      rowId: rowId,
      rowData: this.rows.get(parseInt(rowId))?.originalData || null,
      timestamp: Date.now(),
    });

    this.log(`🖱️🖱️ Double-click pe rândul ${rowIndex} (ID: ${rowId})`);
  },

  /**
   * 📄 UPDATE ROW SELECTION (pentru multiselect)
   */
  updateRowSelection(row, rowIndex, isSelected) {
    if (!window.selectedRows) window.selectedRows = new Set();

    if (isSelected) {
      window.selectedRows.add(rowIndex);
      row.classList.add('selected-multi');
    } else {
      window.selectedRows.delete(rowIndex);
      row.classList.remove('selected-multi');
    }

    // Update "Select All" checkbox state
    this.updateSelectAllCheckbox();

    // Emit event
    this.eventBus.emit(isSelected ? this.EVENTS.ROW_SELECTED : this.EVENTS.ROW_DESELECTED, {
      rowIndex,
      rowId: row.dataset.rowId,
      selectedCount: window.selectedRows.size,
      timestamp: Date.now(),
    });
  },

  /**
   * 📄 UPDATE SELECT ALL CHECKBOX
   */
  updateSelectAllCheckbox() {
    const selectAllCheckbox = document.getElementById('selectAllCheckbox');
    if (!selectAllCheckbox) return;

    const totalRows = document.querySelectorAll('#tableBody tr').length;
    const selectedCount = window.selectedRows ? window.selectedRows.size : 0;

    if (selectedCount === 0) {
      selectAllCheckbox.checked = false;
      selectAllCheckbox.indeterminate = false;
    } else if (selectedCount === totalRows) {
      selectAllCheckbox.checked = true;
      selectAllCheckbox.indeterminate = false;
    } else {
      selectAllCheckbox.checked = false;
      selectAllCheckbox.indeterminate = true;
    }
  },

  /**
   * 🎨 UPDATE VISUAL SELECTION STATE
   */
  updateVisualSelection(row, isSelected, mode = 'single') {
    if (mode === 'single') {
      if (isSelected) {
        row.classList.add('clicked');
        row.classList.remove('selected-multi', 'clicked');

        const indicator = row.querySelector('.record-indicator');
        if (indicator) {
          indicator.style.background = '#4594e92b';
          indicator.style.borderColor = '#0056b3';
        }
      } else {
        row.classList.remove('clicked');

        const indicator = row.querySelector('.record-indicator');
        if (indicator) {
          indicator.style.background = 'transparent';
          indicator.style.borderColor = 'transparent';
        }
      }
    } else if (mode === 'multi') {
      if (isSelected) {
        row.classList.add('selected-multi');
        row.classList.remove('clicked', 'clicked');
      } else {
        row.classList.remove('selected-multi');
      }
    }
  },

  /**
   * 🔄 CLEAR ALL SELECTIONS
   */
  clearAllSelections() {
    // Clear visual selections
    document.querySelectorAll('tr.clicked, tr.selected-multi').forEach((row) => {
      row.classList.remove('clicked', 'selected-multi');

      const indicator = row.querySelector('.record-indicator');
      if (indicator) {
        indicator.style.background = 'transparent';
        indicator.style.borderColor = 'transparent';
      }

      const checkbox = row.querySelector('.record-checkbox, .row-checkbox');
      if (checkbox) {
        checkbox.checked = false;
      }
    });

    // Clear global state
    window.selectedRows?.clear();
    window.currentSelectedRow = null;
    window.currentSelectedRowId = null;

    // Update select all checkbox
    const selectAllCheckbox = document.getElementById('selectAllCheckbox');
    if (selectAllCheckbox) {
      selectAllCheckbox.checked = false;
      selectAllCheckbox.indeterminate = false;
    }

    // Emit event
    this.eventBus.emit(this.EVENTS.SELECTION_CLEARED, {
      timestamp: Date.now(),
    });

    this.log('🧹 Toate selecțiile au fost curățate');
  },

  /**
   * 📊 GET SELECTED ROWS INFO
   */
  getSelectedRowsInfo() {
    const singleSelected = document.querySelector('tr.clicked');
    const multiSelected = document.querySelectorAll('tr.selected-multi');

    return {
      mode: window.multiSelectMode ? 'multi' : 'single',
      singleSelection: singleSelected
        ? {
            rowIndex: parseInt(singleSelected.dataset.rowIndex),
            rowId: singleSelected.dataset.rowId,
            rowData: this.getRowData(parseInt(singleSelected.dataset.rowIndex)),
          }
        : null,
      multiSelection: Array.from(multiSelected).map((row) => ({
        rowIndex: parseInt(row.dataset.rowIndex),
        rowId: row.dataset.rowId,
        rowData: this.getRowData(parseInt(row.dataset.rowIndex)),
      })),
      totalSelected: window.multiSelectMode ? multiSelected.length : singleSelected ? 1 : 0,
    };
  },

  /**
   * 🔄 TOGGLE SELECT MODE
   */
  toggleSelectMode(data) {
    const isActive = data.data.isActive;
    window.multiSelectMode = isActive;

    this.log(`🔄 Mod selecție multiplă: ${isActive ? 'ACTIV' : 'INACTIV'}`);

    // Rebuild pentru a schimba tipul de selector
    this.rebuildTable();
  },
};
