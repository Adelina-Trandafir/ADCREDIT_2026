// File: static/js/table-builder/table-builder-rows.js
/**
 * 📊 TABLE BUILDER ROWS MIXIN
 * Gestionează crearea și renderizarea rândurilor
 *
 * RESPONSABILITĂȚI:
 * ✅ Creare Row objects
 * ✅ Renderizare rânduri în DOM
 * ✅ Formatare valori (date, currency, etc.)
 * ✅ Gestionare celule cu formatare
 * ✅ Action buttons pentru rânduri
 *
 * @version 1.0.0
 */

export const tableBuilderRowsMixin = {
  /**
   * 📊 CREARE ROW OBJECTS
   */
  createRowObjects(rowsData) {
    this.rows.clear();

    rowsData.forEach((rowData, index) => {
      const row = new this.Row(rowData, index);
      this.rows.set(row.id, row);
    });

    this.log(`📊 Creat ${this.rows.size} Row objects`);
  },

  /**
   * 🗂️ BUILD TABLE ROWS (PASUL 2 din build)
   */
  async buildTableRows() {
    const tbody = document.getElementById('tableBody');
    const visibleColumns = this.visibleColumns;
    let rowId;
    let rowIndex = -1;

    if (!tbody) return;

    tbody.innerHTML = '';

    this.rows.forEach((row) => {
      rowId = row.id;
      rowIndex++;

      const tr = document.createElement('tr');
      tr.dataset.rowIndex = rowIndex;
      tr.dataset.rowId = rowId;

      // 🟢 RECORD SELECTOR (PRIMUL)
      const recordSelectorTd = document.createElement('td');
      recordSelectorTd.className = 'record-selector';

      if (window.multiSelectMode) {
        recordSelectorTd.innerHTML = `<input type="checkbox" class="record-checkbox" data-row-index="${rowIndex}">`;
      } else {
        recordSelectorTd.innerHTML = `<div class="record-indicator" data-row-index="${rowIndex}"></div>`;
      }

      // Action buttons în record selector
      this.buildActionButtons(recordSelectorTd, rowIndex);
      tr.appendChild(recordSelectorTd);

      // Checkbox pentru multiselect SEPARAT (dacă e cazul)
      if (window.multiSelectMode) {
        const checkboxTd = document.createElement('td');
        checkboxTd.innerHTML = `<input type="checkbox" class="row-checkbox" data-row-index="${rowIndex}">`;
        tr.appendChild(checkboxTd);
      }

      // 📊 CELULE pentru fiecare coloană
      visibleColumns.forEach((col, columnIndex) => {
        const column = this.columns.get(col.id);
        const td = document.createElement('td');

        const cellData = column.id ? row.data?.[column.id] : row.data?.[column.field] || '';

        // Procesare celulă cu formatare
        if (cellData && typeof cellData === 'object') {
          td.textContent = this.formatValue(cellData.value, column.type);

          if (!window.multiSelectMode || !window.selectedRows?.has(rowIndex)) {
            td.style.backgroundColor = cellData.back_color || '#FFFFFF';
            td.style.color = cellData.fore_color || '#000000';
            td.style.fontWeight = cellData.font_bold ? 'bold' : 'normal';
            td.style.fontStyle = cellData.font_italic ? 'italic' : 'normal';
            td.style.textDecoration = cellData.font_underline ? 'underline' : 'none';
          }
        } else {
          td.textContent = this.formatValue(cellData || '', column.type);
        }

        // Styling coloană
        td.style.textAlign = column.align;

        if (columnIndex === 0) {
          td.style.width =
            parseFloat(column.width) + this.remainingSpace + this.extraColumnSpace + 'px';
          td.style.minWidth =
            parseFloat(column.width) + this.remainingSpace + this.extraColumnSpace + 'px';
          td.style.maxWidth =
            parseFloat(column.width) + this.remainingSpace + this.extraColumnSpace + 'px';
        } else {
          td.style.width = parseFloat(column.width) + this.extraColumnSpace + 'px';
          td.style.minWidth = parseFloat(column.width) + this.extraColumnSpace + 'px';
          td.style.maxWidth = parseFloat(column.width) + this.extraColumnSpace + 'px';
        }

        td.title = td.textContent;

        if (column.special) {
          td.classList.add('special-cell');
        }

        tr.appendChild(td);
        tr.classList.add('record');
      });

      tbody.appendChild(tr);
    });
  },

  /**
   * 🎨 BUILD ACTION BUTTONS pentru rând
   */
  buildActionButtons(recordSelectorTd, rowIndex) {
    const actionButtons = document.createElement('div');
    actionButtons.className = 'row-action-buttons';

    // Edit
    const editBtn = document.createElement('button');
    editBtn.id = `edit-btn-${rowIndex}`;
    editBtn.className = 'row-action-btn edit';
    editBtn.dataset.tooltip = 'Modifică';
    editBtn.textContent = '✏️';
    editBtn.addEventListener('click', () => this.handleRowOptionsClick(editBtn));

    // Feedback
    const feedbackBtn = document.createElement('button');
    feedbackBtn.id = `feedback-btn-${rowIndex}`;
    feedbackBtn.className = 'row-action-btn feedback';
    feedbackBtn.dataset.tooltip = 'Adaugă feedback';
    feedbackBtn.textContent = '💬';
    feedbackBtn.addEventListener('click', () => this.handleRowOptionsClick(feedbackBtn));

    // Delete
    const deleteBtn = document.createElement('button');
    deleteBtn.id = `delete-btn-${rowIndex}`;
    deleteBtn.className = 'row-action-btn delete';
    deleteBtn.dataset.tooltip = 'Șterge';
    deleteBtn.textContent = '🗑️';
    deleteBtn.addEventListener('click', () => this.handleRowOptionsClick(deleteBtn));

    // Transfer Lead
    const transferBtn = document.createElement('button');
    transferBtn.id = `transfer-btn-${rowIndex}`;
    transferBtn.className = 'row-action-btn tl-row-menu-btn';
    transferBtn.dataset.tooltip = 'Transferă Lead';
    transferBtn.title = 'Transferă Lead';
    transferBtn.textContent = '▶';
    transferBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      const tr = transferBtn.closest('tr');
      if (!tr) return;
      const rowId = tr.dataset.rowId;
      const rowData = this.rows.get(parseInt(rowId))?.originalData || null;
      this.eventBus.emit(this.EVENTS.TRANSFER_LEAD_OPEN_REQUEST, { rowId, rowData });
    });

    actionButtons.append(editBtn, feedbackBtn, deleteBtn, transferBtn);
    recordSelectorTd.appendChild(actionButtons);
  },

  /**
   * 🖱️ HANDLE ROW OPTIONS CLICK
   */
  handleRowOptionsClick(optionsButton) {
    let rowIndex = null;
    optionsButton.blur();

    const row = optionsButton.closest('tr');
    if (!row || !row.dataset.rowId) return;

    rowIndex = parseInt(optionsButton.closest('tr')?.dataset.rowIndex);

    // Remove hover class
    optionsButton.parentElement.classList.remove('hover');

    // Emit event
    this.eventBus.emit(this.EVENTS.ROW_OPTIONS_CLICKED, {
      rowIndex,
      rowElement: row,
      rowId: row.dataset.rowId,
      rowData: this.rows.get(parseInt(row.dataset.rowId))?.originalData || null,
      rowAction:
        optionsButton.id && optionsButton.id.includes('-')
          ? optionsButton.id.split('-')[0]
          : 'unknown',
      source: 'table',
      timestamp: Date.now(),
    });
  },

  /**
   * 🔧 FORMAT VALUE - Formatare după tip
   */
  formatValue(value, format) {
    if (!value && value !== 0) return '';

    switch (format) {
      case 'CURRENCY':
        const num = parseFloat(value);
        return !isNaN(num)
          ? num.toLocaleString('ro-RO', {
              style: 'currency',
              currency: 'RON',
              minimumFractionDigits: 2,
            })
          : value;

      case 'DATE':
      case 'date':
        const date = new Date(value);
        return date
          .toLocaleDateString('ro-RO', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
          })
          .split('.')
          .join('/');

      case 'PERCENT':
        const percent = parseFloat(value);
        return !isNaN(percent) ? percent.toFixed(2) + '%' : value;

      case 'NUMBER':
        const number = parseFloat(value);
        return !isNaN(number) ? number.toLocaleString('ro-RO') : value;

      case 'varchar':
      case 'text':
        return value.toString();

      default:
        this.log.error(`🔧 Format necunoscut: ${format} pentru valoarea: ${value}`);
        return value;
    }
  },

  /**
   * 📊 GET ROW DATA helper
   */
  getRowData(rowIndex) {
    if (window.tableData && window.tableData[rowIndex]) {
      return window.tableData[rowIndex];
    }
    return null;
  },

  /**
   * 📊 UPDATE ROW STATISTICS (pentru refresh rapid)
   */
  updateRowStatistics(data) {
    window.dataLength = data.length;
    window.currentData = data;

    const recordCountElement = document.getElementById('recordCount');
    if (recordCountElement) {
      const totalColumns = window.columnsMetadata?.length || this.visibleColumns.length;
      recordCountElement.textContent = `${data.length} înregistrări | Coloane afișate: ${this.visibleColumns.length} din ${totalColumns}`;
    }

    const dataTable = document.getElementById('dataTable');
    if (dataTable) {
      dataTable.style.display = 'table';
    }
  },
};
