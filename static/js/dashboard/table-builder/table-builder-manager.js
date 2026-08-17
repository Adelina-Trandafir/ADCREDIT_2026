/**
 * 🗂️ TABLE BUILDER MANAGER - Main Orchestrator
 *
 * RESPONSABILITĂȚI:
 * ✅ Singleton pattern
 * ✅ Initialization
 * ✅ Mixin composition
 * ✅ Public API
 * ✅ Logging
 *
 * @version 3.0.0
 */

import eventBus, { EVENTS } from '../../event-bus/event-bus.js';
import { getInstance, registerInstance } from '../../instances-registry.js';
import ListenerTracker from '../../listener-tracker/listener-tracker-mixin.js';
import Column from './column.js';
import Row from './row.js';

// 🎯 IMPORT MIXINS
import { tableBuilderColumnsMixin } from './table-builder-columns.js';
import { tableBuilderRowsMixin } from './table-builder-rows.js';
import { tableBuilderHeaderMixin } from './table-builder-header.js';
import { tableBuilderSelectorMixin } from './table-builder-selector.js';
import { tableBuilderUIMixin } from './table-builder-ui.js';
import { tableBuilderEventsMixin } from './table-builder-events.js';

class TableBuilder {
  constructor() {
    // Singleton check
    if (TableBuilder.instance) {
      console.warn('⚠️ TableBuilder is singleton');
      return TableBuilder.instance;
    }

    this.debugMode = true;
    TableBuilder.instance = this;

    // 🎯 APPLY LISTENER TRACKER
    ListenerTracker.applyTo(this, {
      debugMode: this.debugMode,
      logPrefix: 'TableBuilder',
      trackPerformance: true,
    });

    this.eventBus = eventBus;
    this.Column = Column;
    this.Row = Row;
    this.EVENTS = EVENTS;
    this.getInstance = getInstance;
    this.registerInstance = registerInstance;
    this.ListenerTracker = ListenerTracker;
    this.extraColumnSpace = 24; //spatiu pentru record-selector

    // 🎯 APPLY MIXINS
    Object.assign(this, tableBuilderColumnsMixin);
    Object.assign(this, tableBuilderRowsMixin);
    Object.assign(this, tableBuilderHeaderMixin);
    Object.assign(this, tableBuilderSelectorMixin);
    Object.assign(this, tableBuilderUIMixin);
    Object.assign(this, tableBuilderEventsMixin);

    // 🎯 STATE
    this.isInitialized = false;
    this.isBuilding = false;
    this.isTableBuilt = false;
    this.timesBuilt = 0;

    // Collections
    this.columns = new Map();
    this.rows = new Map();
    this.visibleColumns = [];

    // 🎯 AUTO-REGISTER
    registerInstance('tableBuilder', this, {
      version: '3.0.0',
      description: 'Modular table builder with mixins',
      features: ['columns', 'rows', 'header', 'selector', 'ui', 'events'],
    });
  }

  /**
   * 🚀 INIT - Păstrează compatibilitatea
   */
  init() {
    if (this.isInitialized) {
      this.log('⚠️ TableBuilder deja inițializat');
      return true;
    }

    this.setupEventListeners(); // Din events mixin
    this.isInitialized = true;
    this.log('✅ TableBuilder inițializat complet');
    return true;
  }

  /**
   * 🔧 BUILD TABLE - API public (compatibilitate)
   * Logica internă în mixins
   */
  buildTable() {
    const startTime = performance.now();
    this.isBuilding = true;

    try {
      // Obține date
      const data = getInstance('dataLoader').rowsData;
      const metadata = getInstance('dataLoader').columnsData;
      const allColumns = getInstance('dataLoader').allColumns;

      // Validare (din UI mixin)
      if (!this.validateTableData(data, metadata, allColumns)) {
        this.showEmptyTable();
        return;
      }

      // Build în 3 pași (din mixins)
      this.visibleColumns = this.calculateVisibleColumns(metadata, null); // columns mixin
      this.createColumnObjects(allColumns); // columns mixin
      this.createRowObjects(data); // rows mixin

      this.buildTableHeader(); // header mixin
      this.buildTableRows(); // rows mixin
      this.buildTableFooter(data, metadata); // UI mixin
      this.setupRecordSelectorEvents(); // selector mixin

      // State update
      this.isTableBuilt = true;
      this.timesBuilt++;

      const buildTime = performance.now() - startTime;
      this.updateBuildMetrics(buildTime);

      // Emit event
      eventBus.emit(EVENTS.TABLE_BUILD_COMPLETE, {
        rowCount: data.length,
        columnCount: this.visibleColumns.length,
        buildTime,
        currentWindowSize: {
          width: window.innerWidth,
          height: window.innerHeight,
        },
        timestamp: Date.now(),
      });

      this.log(`✅ Tabel construit în ${buildTime.toFixed(2)}ms`);
    } catch (error) {
      this.log.error('❌ Eroare la buildTable', error);
      this.handleError('Eroare la construirea tabelului', error);
    } finally {
      this.isBuilding = false;
    }
  }

  /**
   * 🔄 REBUILD TABLE - API public (compatibilitate)
   */
  rebuildTable(availableSpace = 0) {
    this.log('🔄 Reconstruire tabel...');

    // Clear (din columns/rows mixins)
    this.clearColumnEventHandlers();
    this.rows.clear();
    this.visibleColumns = [];

    const rowsData = getInstance('dataLoader').rowsData;
    const colsData = getInstance('dataLoader').columnsData;

    if (!rowsData || !colsData) {
      this.showEmptyTable();
      return;
    }

    // Rebuild logic (din mixins)
    this.visibleColumns = this.calculateVisibleColumns(colsData, availableSpace);
    this.createRowObjects(rowsData);

    this.buildTableHeader();
    this.buildTableRows();
    this.buildTableFooter(rowsData, colsData);

    this.isTableBuilt = true;
    this.timesBuilt++;
  }

  /**
   * 🗑️ DESTROY - Compatibilitate
   */
  destroy() {
    this.log('🗑️ Începe distrugerea TableBuilder...');

    const cleanupStats = this.cleanupAllListeners();

    this.columns.clear();
    this.rows.clear();
    this.visibleColumns = [];

    this.isInitialized = false;
    this.isBuilding = false;
    this.isTableBuilt = false;

    TableBuilder.instance = null;
    this.log('✅ TableBuilder distrus complet', cleanupStats);
  }

  /**
   * 📊 LOGGING
   */
  log = (() => {
    const fn = (message, data = null) => {
      if (this.debugMode) {
        const now = new Date();
        const ts = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now.getMilliseconds().toString().padStart(3, '0')}`;
        console.log(
          `%c[${ts}] [TableBuilder] ${message}`,
          'color: #889bbaff; font-weight: bold;',
          data ?? ''
        );
      }
    };
    fn.error = (message, data = null) => {
      const now = new Date();
      const ts = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now.getMilliseconds().toString().padStart(3, '0')}`;
      console.error(
        `%c[${ts}] [TableBuilder] ${message}`,
        'color: #ef4444; font-weight: bold;',
        data ?? ''
      );
    };
    return fn;
  })();
}

const tableBuilder = new TableBuilder();
export default tableBuilder;
