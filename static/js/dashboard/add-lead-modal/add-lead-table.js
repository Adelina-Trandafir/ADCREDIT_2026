// js/components/dashboard/add-lead-modal/add-lead-table.js
/**
 * 📊 ADD LEAD TABLE MIXIN
 * Gestionează tabelul cu rezultate verificare telefon
 *
 * @version 1.0.0
 */

export const addLeadTableMixin = {
  /**
   * Renderizează tabelul cu date
   * @param {Array} data - Date de afișat
   */
  renderTable(data) {
    if (!this.tableBodyElement) {
      this.log.error('❌ Table body element nu există');
      return;
    }

    if (!data || data.length === 0) {
      this.renderEmptyTable();
      return;
    }

    this.log(`📊 Renderizez tabel cu ${data.length} rânduri`);

    // Salvează datele în cache
    this.tableData = data;

    // Verifică dacă există rânduri cu Util='NU'
    const hasUnusable = data.Util === 'NU';

    // Construiește HTML
    const html = data.records
      .map((row, index) => {
        const isUnusable = row.Util === 'NU';
        const bgColor = row.BackColor || '#ffffff';

        return `
        <tr 
          data-index="${index}" 
          data-util="${row.Util}"
          cursor: ${isUnusable ? 'not-allowed' : 'pointer'};
          class="${isUnusable ? 'row-unusable' : 'row-selectable'}"
        >
          <td class="record-selector ${isUnusable ? 'unchecked' : 'checked'}" style="background-color: ${bgColor};"></td>
          <td>${this.escapeHtml(row.Consultant || '-')}</td>
          <td>${this.escapeHtml(row.TelefonConsultant || '-')}</td>
          <td>${this.formatDate(row.DataPrimire)}</td>
          <td>${this.escapeHtml(row.StatusFinal || '-')}</td>
        </tr>
      `;
      })
      .join('');

    this.tableBodyElement.innerHTML = html;

    // Setup row listeners
    this.setupTableRowListeners();

    // Arată secțiunea tabel
    this.showTableSection();

    // Dacă toate sunt utilizabile, arată footer-ul
    if (!hasUnusable) {
      this.log('✅ Toate rândurile sunt utilizabile');
    } else {
      this.log('⚠️ Există rânduri neutilizabile, OK dezactivat');
      this.setButtonState('ok', false);
    }

    this.log('✅ Tabel renderizat cu succes');
  },

  /**
   * Renderizează tabel gol
   */
  renderEmptyTable() {
    if (!this.tableBodyElement) return;

    this.tableBodyElement.innerHTML = `
      <tr>
        <td colspan="4" class="no-data">Nu există date</td>
      </tr>
    `;

    this.hideTableSection();
    this.log('📭 Tabel gol renderizat');
  },

  /**
   * Renderizează stare loading
   */
  renderTableLoading() {
    if (!this.tableBodyElement) return;

    this.tableBodyElement.innerHTML = `
      <tr>
        <td colspan="4" class="loading">Se încarcă...</td>
      </tr>
    `;

    //this.showTableSection();
    this.log('⏳ Tabel în stare loading');
  },

  /**
   * Renderizează eroare
   */
  renderTableError(message = 'Eroare la încărcarea datelor') {
    if (!this.tableBodyElement) return;

    this.tableBodyElement.innerHTML = `
      <tr>
        <td colspan="4" class="error">${this.escapeHtml(message)}</td>
      </tr>
    `;

    this.showTableSection();
    this.log.error(`❌ Eroare tabel: ${message}`);
  },

  /**
   * Curăță tabelul
   */
  clearTable() {
    this.tableData = [];
    this.selectedRow = null;
    this.renderEmptyTable();
    this.hideTableSection();
    this.log('🧹 Tabel curățat');
  },

  /**
   * Setup listeners pentru rândurile tabelului
   */
  setupTableRowListeners() {
    const rows = this.tableBodyElement.querySelectorAll('tr.row-selectable');

    rows.forEach((row) => {
      // Click listener
      this.addDOMListener(row, 'click', (e) => {
        e.preventDefault();
        const index = parseInt(row.dataset.index);
        this.handleRowSelect(index);
      });

      // Hover effect (doar pentru rânduri selectabile)
      this.addDOMListener(row, 'mouseenter', () => {
        if (!row.classList.contains('row-selected')) {
          row.style.backgroundColor = '#f3f4f6';
        }
      });

      this.addDOMListener(row, 'mouseleave', () => {
        if (!row.classList.contains('row-selected')) {
          const index = parseInt(row.dataset.index);
          const originalColor = this.tableData[index]?.BkColor || '#ffffff';
          row.style.backgroundColor = originalColor;
        }
      });
    });

    this.log('✅ Row listeners configurați');
  },

  /**
   * Handler pentru selectarea unui rând
   */
  handleRowSelect(index) {
    if (index < 0 || index >= this.tableData.length) {
      this.log.error(`❌ Index invalid: ${index}`);
      return;
    }

    const row = this.tableData[index];

    // Verifică dacă rândul e utilizabil
    if (row.Util === 'NU') {
      this.log('⚠️ Rând neutilizabil, nu poate fi selectat');
      return;
    }

    this.log(`✅ Rând selectat: ${index}`, row);

    // Salvează rândul selectat
    this.selectedRow = row;

    // Update UI
    this.highlightSelectedRow(index);

    // Activează butonul Vechi
    this.setButtonState('vechi', true);

    // Resetează actionType dacă era setat pe 'old_new'
    if (this.actionType === 'old_new') {
      this.actionType = null;
      this.setButtonState('ok', false);
    }
  },

  /**
   * Highlight rând selectat
   */
  highlightSelectedRow(index) {
    const rows = this.tableBodyElement.querySelectorAll('tr');

    rows.forEach((row, i) => {
      row.classList.remove('row-selected');

      if (i === index) {
        row.classList.add('row-selected');
        row.style.backgroundColor = '#dbeafe'; // Light blue
      } else {
        const originalColor = this.tableData[i]?.BkColor || '#ffffff';
        row.style.backgroundColor = originalColor;
      }
    });

    this.log(`🎯 Rând ${index} highlighted`);
  },

  /**
   * Curăță selecția rânduri
   */
  clearRowSelection() {
    const rows = this.tableBodyElement.querySelectorAll('tr');

    rows.forEach((row, i) => {
      row.classList.remove('row-selected');
      const originalColor = this.tableData[i]?.BkColor || '#ffffff';
      row.style.backgroundColor = originalColor;
    });

    this.selectedRow = null;
    this.setButtonState('vechi', false);

    this.log('🧹 Selecție rânduri curățată');
  },

  /**
   * Formatează data
   */
  formatDate(dateStr) {
    if (!dateStr) return '-';

    try {
      const date = new Date(dateStr);
      return date.toLocaleDateString('ro-RO', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
      });
    } catch (e) {
      return dateStr;
    }
  },

  /**
   * Escape HTML pentru siguranță
   */
  escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  },
};
