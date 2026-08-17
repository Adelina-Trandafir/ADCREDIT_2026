// File: static/js/table-builder/table-builder-header.js
/**
 * 📋 TABLE BUILDER HEADER MIXIN
 * Gestionează construcția header-ului tabelului
 *
 * RESPONSABILITĂȚI:
 * ✅ Construcție header cu coloane
 * ✅ Record selector header
 * ✅ Select all checkbox (multiselect)
 * ✅ Iconițe pentru sort și filtru
 * ✅ Styling și dimensionare
 *
 * @version 1.0.0
 */

export const tableBuilderHeaderMixin = {
  /**
   * 🗂️ BUILD TABLE HEADER (PASUL 1 din build)
   */
  buildTableHeader() {
    const thead = document.getElementById('tableHeaders');
    const visibleColumns = this.visibleColumns;

    if (!thead) return;

    thead.innerHTML = '';

    const tr = document.createElement('tr');

    // 🟢 RECORD SELECTOR HEADER (LA ÎNCEPUT)
    const recordSelectorTh = document.createElement('th');
    recordSelectorTh.className = 'header-record-selector';
    recordSelectorTh.style.width = '25px';
    recordSelectorTh.style.minWidth = '25px';
    recordSelectorTh.style.maxWidth = '25px';
    tr.appendChild(recordSelectorTh);

    // ☑️ CHECKBOX pentru select all (dacă e multiselect)
    if (window.multiSelectMode) {
      const checkboxTh = document.createElement('th');
      checkboxTh.style.width = '40px';
      checkboxTh.innerHTML =
        '<input type="checkbox" id="selectAllCheckbox" style="cursor: pointer;">';
      tr.appendChild(checkboxTh);
    }

    // 📊 HEADER pentru fiecare coloană vizibilă
    visibleColumns.forEach((col, columnIndex) => {
      const column = this.columns.get(col.id);

      const sortIcon = this.getSortIcon(column);
      const filterOpenIcon = this.getFilterOpenIcon(column);

      const colTh = document.createElement('th');
      colTh.id = `header-${column.id}`;
      colTh.dataset.column = column.id;
      colTh.dataset.field = column.field;
      colTh.dataset.type = column.type;
      colTh.dataset.columnIndex = columnIndex;

      const innerDiv = document.createElement('div');
      innerDiv.id = `header-inner-${column.id}`;
      innerDiv.className = 'header-inner-div';

      // 🔧 ZONA ICONIȚE ACȚIUNI (stânga)
      const iconsDiv = document.createElement('div');
      iconsDiv.id = `header-icons-${column.id}`;
      iconsDiv.className = 'header-icons-div';
      iconsDiv.innerHTML = filterOpenIcon;
      innerDiv.appendChild(iconsDiv);

      // 📝 ZONA TITLU COLOANĂ (mijloc)
      const titleSpan = document.createElement('span');
      titleSpan.id = `header-title-${column.id}`;
      titleSpan.className = 'header-title-span';
      titleSpan.textContent = column.header;
      innerDiv.appendChild(titleSpan);

      // 🎯 ZONA STATUS ACTIV (dreapta) - sort + filtru aplicat
      const statusDiv = document.createElement('div');
      statusDiv.id = `header-status-${column.id}`;
      statusDiv.className = 'header-status-area';

      // 🔍 VERIFICĂ DACĂ COLOANA ARE FILTRU ACTIV
      const filterManager = this.getInstance('filterManager');
      if (filterManager && filterManager.activeFilters.has(column.id)) {
        const filterStatusIcon = this.getFilterStatusIcon(column);
        statusDiv.innerHTML = filterStatusIcon + sortIcon;
      } else {
        statusDiv.innerHTML = sortIcon;
      }

      innerDiv.appendChild(statusDiv);
      colTh.appendChild(innerDiv);
      colTh.className = 'column-header-clickable';

      // 📏 DIMENSIONARE COLOANĂ
      if (columnIndex === 0) {
        // First column special case
        colTh.style.width =
          parseFloat(column.width) + this.extraColumnSpace + this.remainingSpace + 'px';
        colTh.style.minWidth =
          parseFloat(column.width) + this.extraColumnSpace + this.remainingSpace + 'px';
        colTh.style.maxWidth =
          parseFloat(column.width) + this.extraColumnSpace + this.remainingSpace + 'px';
      } else {
        colTh.style.width = parseFloat(column.width) + this.extraColumnSpace + 'px';
        colTh.style.minWidth = parseFloat(column.width) + this.extraColumnSpace + 'px';
        colTh.style.maxWidth = parseFloat(column.width) + this.extraColumnSpace + 'px';
      }

      tr.appendChild(colTh);
    });

    thead.innerHTML = '';
    thead.appendChild(tr);

    // Setup event handlers
    this.setupColumnEventHandlers(visibleColumns);
  },

  /**
   * 📊 BUILD TABLE FOOTER (PASUL 3 din build)
   */
  buildTableFooter() {
    const data = this.getInstance('dataLoader').rowsData;
    const metadata = this.getInstance('dataLoader').columnsData;

    document.getElementById('dataTableHeader').style.display = 'table';

    document.getElementById('recordCount').textContent =
      `${data.length} înregistrări | Coloane afișate: ${this.visibleColumns.length} din ${metadata.length}`;

    this.log('🏁 Tabel finalizat cu succes');
  },

  /**
   * 📊 EVENT HANDLERS pentru column state changes
   */
  filterApplied(data) {
    const column = this.columns.get(data.data.id);
    if (column) {
      this.updateColumnVisual(column);
    }
  },

  filterCleared(data) {
    const column = this.columns.get(data.data.id);
    if (column) {
      column.clearFilter();
      this.updateColumnVisual(column);
    }
  },

  onColumnSortChanged(data) {
    this.columns.forEach((col) => col.clearSort());

    const column = this.columns.get(data.columnId);
    if (column) {
      column.setSortDirection(data.direction);
      this.updateAllColumnVisuals();
    }
  },
};
