// File: static/js/table-builder/table-builder-ui.js
/**
 * 🎭 TABLE BUILDER UI MIXIN
 * Gestionează stările UI ale tabelului
 *
 * RESPONSABILITĂȚI:
 * ✅ Loading states (spinner)
 * ✅ Empty table state
 * ✅ Error states
 * ✅ Validare date
 * ✅ Performance metrics
 *
 * @version 1.0.0
 */

export const tableBuilderUIMixin = {
  /**
   * 🎭 ARATĂ LOADING ANIMATION DOAR ÎN TBODY
   */
  showTableLoading(message = 'Se încarcă datele...') {
    const dataTable = document.getElementById('tableWrapper');
    if (!dataTable) {
      this.log.error('❌ Nu găsesc #tableWrapper pentru a adăuga loading');
      return;
    }

    let tbody = dataTable.querySelector('tbody');
    if (!tbody) {
      tbody = document.createElement('tbody');
      dataTable.appendChild(tbody);
    }

    // 🧹 ȘTERGE TOATE RÂNDURILE EXISTENTE ÎNAINTE DE LOADING
    const existingRows = tbody.querySelectorAll('tr');
    const deletedRowsCount = existingRows.length;
    tbody.innerHTML = '';

    if (deletedRowsCount > 0) {
      this.log(`🧹 Șterse ${deletedRowsCount} rânduri existente din tbody`);
    }

    // Calculez din header-ele existente
    const headerCells = document.querySelectorAll('#tableHeaders th[id^="header-"]');
    const colCount = headerCells.length;

    if (colCount === 0) {
      this.log.error('❌ Nu găsesc header-e cu id header-XX în #tableHeaders');
      return;
    }

    this.log(`🎭 Creez loading pentru ${colCount} coloane`);

    const loadingHTML = `
    <tr id="table-rows-loading">
      <td colspan="${colCount}" style="
        text-align: center;
        padding: 50px 20px;
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        border: none;
        position: relative;
        width: 100% !important;
        min-width: 100% !important;
        box-sizing: border-box !important;
      ">
        <div style="display: flex; flex-direction: column; align-items: center;">
          <!-- Spinner animat -->
          <div class="loading-spinner" style="
            width: 40px;
            height: 40px;
            border: 4px solid #e9ecef;
            border-top: 4px solid #007bff;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-bottom: 20px;
          "></div>
          
          <!-- Mesaj loading -->
          <div style="
            color: #495057;
            font-size: 16px;
            font-weight: 500;
            margin-bottom: 5px;
          ">${message}</div>
          
          <!-- Submesaj -->
          <div style="
            color: #6c757d;
            font-size: 13px;
          ">Vă rugăm să așteptați...</div>
        </div>
      </td>
    </tr>
    
    <style>
      /* Forțează tabelul să aibă layout fix */
      #tableWrapper table {
        table-layout: fixed !important;
        width: 100% !important;
      }
      
      /* Asigură că tbody ocupă toată lățimea */
      #tableWrapper tbody {
        width: 100% !important;
      }
      
      /* Forțează loading row să ocupe toată lățimea */
      #table-rows-loading td {
        width: 100% !important;
        min-width: 100% !important;
        display: table-cell !important;
      }
      
      @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
      }
    </style>
  `;

    tbody.innerHTML = loadingHTML;
    this.log(`🎭 Loading animation afișată (${deletedRowsCount} rânduri șterse → loading adăugat)`);
  },

  /**
   * 🎭 ASCUNDE LOADING DIN TBODY
   */
  hideTableLoading() {
    const loadingRow = document.getElementById('table-rows-loading');
    if (loadingRow) {
      loadingRow.remove();
      this.log('🎭 Loading animation ascunsă din rânduri');
    }
  },

  /**
   * 📭 SHOW EMPTY TABLE
   */
  showEmptyTable() {
    document.getElementById('tableBody').innerHTML =
      '<tr><td colspan="100%" style="text-align: center; padding: 20px;">Nu există date pentru afișare</td></tr>';
    document.getElementById('recordCount').textContent = '0 înregistrări';

    this.eventBus.emit(this.EVENTS.TABLE_EMPTY, {
      message: 'Nu există date pentru afișare',
      timestamp: Date.now(),
    });

    this.log('📭 Tabel gol afișat');
  },

  /**
   * ✅ VALIDARE DATE TABEL
   */
  validateTableData(data, metadata, allColumns) {
    if (!data || !metadata || !allColumns || !Array.isArray(data) || !Array.isArray(metadata)) {
      this.log.error('❌ Date invalide:', {
        data: Array.isArray(data) ? data.length : 'invalid',
        metadata: Array.isArray(metadata) ? metadata.length : 'invalid',
        allColumns: Array.isArray(allColumns) ? allColumns.length : 'invalid',
      });
      return false;
    }

    if (data.length === 0) {
      this.log('⚠️ Date goale');
      return false;
    }

    return true;
  },

  /**
   * 🔄 REFRESH TABLE ROWS (optimizat pentru filtre/sort)
   */
  refreshTableRows(Data) {
    const startTime = performance.now();

    if (!Data) {
      this.log.error('❌ refreshTableRows: Date invalide', Data);
      this.showEmptyTable();
      return;
    }

    // Verifică dacă avem coloane vizibile deja create
    if (!this.visibleColumns || this.visibleColumns.length === 0) {
      this.log.error('❌ refreshTableRows: Nu există coloane vizibile');
      return;
    }

    this.log(`🔄 Refresh rânduri: ${Data.data.rowsData.length} rânduri`);

    try {
      // DOAR PASUL 2: Reconstituie rândurile
      this.buildTableRows(Data.data.rowsData, this.visibleColumns);

      // UPDATE RAPID STATISTICS
      this.updateRowStatistics(Data.data.rowsData);

      const refreshTime = performance.now() - startTime;
      this.log(`✅ Rânduri refresh-uite în ${refreshTime.toFixed(2)}ms`);
    } catch (error) {
      this.log.error('❌ Eroare la refresh rânduri:', error);
      this.handleError('Eroare la refresh rânduri', error);
    }
  },

  /**
   * 📊 UPDATE BUILD METRICS
   */
  updateBuildMetrics(buildTime) {
    if (!this.buildMetrics) {
      this.buildMetrics = {
        totalBuilds: 0,
        avgBuildTime: 0,
        lastBuildTime: 0,
        totalBuildTime: 0,
      };
    }

    this.buildMetrics.totalBuilds++;
    this.buildMetrics.lastBuildTime = buildTime;
    this.buildMetrics.totalBuildTime += buildTime;
    this.buildMetrics.avgBuildTime =
      this.buildMetrics.totalBuildTime / this.buildMetrics.totalBuilds;
  },

  /**
   * 📈 GET PERFORMANCE METRICS
   */
  getPerformanceMetrics() {
    return {
      builder: this.buildMetrics || {},
      columns: Array.from(this.columns.values()).map((col) => ({
        id: col.id,
        name: col.header,
        metrics: col.getMetrics(),
      })),
    };
  },

  /**
   * 📊 GET STATE
   */
  getState() {
    return {
      isInitialized: this.isInitialized,
      isBuilding: this.isBuilding,
      isTableBuilt: this.isTableBuilt,
      timesBuilt: this.timesBuilt,
      columnsCount: this.columns.size,
      visibleColumnsCount: this.visibleColumns.length,
      lastColumnHovered: this.lastColumnHoveredID,
    };
  },

  /**
   * 🛑 ERROR HANDLING
   */
  handleError(message, error) {
    console.error(`❌ TableBuilder: ${message}`, error);

    this.eventBus.emit(this.EVENTS.TABLE_BUILD_ERROR, {
      source: 'TableBuilder',
      message,
      error: error.message || error,
      timestamp: Date.now(),
    });

    this.isBuilding = false;
  },

  /**
   * 📊 DEBUG TABLE BUILDER
   */
  debugTableBuilder() {
    const listenerStats = this.getListenerStats();
    const columnStats = {
      totalColumns: this.columns.size,
      visibleColumns: this.visibleColumns.length,
      columnsWithFilters: Array.from(this.columns.values()).filter((c) => c.hasFilter).length,
      columnsWithSort: Array.from(this.columns.values()).filter((c) => c.sortDirection).length,
    };

    const stats = {
      ...this.buildMetrics,
      listeners: listenerStats,
      columns: columnStats,
      state: {
        isInitialized: this.isInitialized,
        isBuilding: this.isBuilding,
        isTableBuilt: this.isTableBuilt,
        timesBuilt: this.timesBuilt,
      },
    };

    this.log('📊 Statistici complete TableBuilder:', stats);
    return stats;
  },
};
