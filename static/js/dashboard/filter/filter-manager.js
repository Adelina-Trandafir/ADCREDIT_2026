/**
 * 🎯 FILTER MANAGER - CORE ORCHESTRATOR
 * Singleton pattern + Mixin composition (după modelul feedback-modal)
 *
 * RESPONSABILITĂȚI:
 * ✅ Singleton enforcement
 * ✅ Mixin composition
 * ✅ Global state management
 * ✅ Listener tracking
 * ✅ Public API coordination
 *
 * @version 4.0.0 - MODULAR ARCHITECTURE
 * @author Adelina Trandafir - Avatar Soft SRL
 */

//import '../../global-variables.js';
import eventBus, { EVENTS } from '../../event-bus/event-bus.js';
import ListenerTracker from '../../listener-tracker/listener-tracker-mixin.js';
import { registerInstance, getInstance } from '../../instances-registry.js';
import { Combobox } from '../../components/combobox/combobox.js';
import { CalendarManager } from '../../components/calendar/calendar-manager.js';

// 📦 IMPORT MIXINS
import { filterModalWindow } from './filter-modal-window.js';
import { filterUtilsMixin } from './filter-utils.js';
import { filterColumnsMixin } from './filter-columns.js';
import { filterUIMixin } from './filter-ui.js';
import { filterSQLMixin } from './filter-sql.js';
import { filterFormMixin } from './filter-form.js';
import { filterEventsHandlersMixin } from './filter-events-handlers.js';
import { filterEventsMixin } from './filter-events.js';

class FilterManager {
  constructor() {
    // Singleton check
    if (FilterManager.instance) {
      console.warn('⚠️ FilterManager is singleton, returning existing instance');
      return FilterManager.instance;
    }

    this.debugMode = false;
    this.Combobox = Combobox;
    this.eventBus = eventBus;
    this.getInstance = getInstance;
    this.isVisible = false;

    // 🎯 APLICĂ LISTENER TRACKER
    ListenerTracker.applyTo(this, {
      debugMode: this.debugMode,
      logPrefix: 'FilterManager',
      trackPerformance: true,
    });

    // 🎭 STATE - Modal filter window
    this.modalElement = null;
    // this.overlayElement = null;

    // 📦 STATE - DOM Elements
    this.headerElement = null;
    this.applyBtnElement = null;
    this.clearBtnElement = null;

    this.optionElements = {};
    this.optionButtons = {};
    this.exactFilterContainer = null;
    this.partialFilterContainer = null;
    this.rangeFilterContainer = null;
    this.partialTextElement = null;
    this.comboboxElement = null;
    this.rangeFromElement = null;
    this.rangeToElement = null;

    // 📦 STATE - Combobox
    this.exactCombobox = null;
    this.cbxStaticData = null;
    this.cbxSelectedValue = 0;
    this.useReadOnlyCbx = false;

    // 📦 STATE - Columns
    this.currentColumn = null;
    this.currentColumnId = '';
    this.currentColumnType = '';
    this.currentColumnName = '';
    this.currentColumnPK = '';

    // 📦 STATE - Calendar
    this.calendarManager = new CalendarManager();
    this.calendarFrom = null;
    this.calendarTo = null;

    // 📦 STATE - Field availability
    this.isExactAvailable = false;
    this.isPartialAvailable = false;
    this.isRangeAvailable = false;

    // 📊 STATE CENTRALIZAT
    this.modalState = {
      isOpen: false,
      currentColumn: null,
      // currentField: null,
      currentType: null,
      currentFilterConfig: null,
    };

    this.normalState = {
      isVisible: false,
      currentColumn: null,
      // currentField: null,
      currentType: null,
      currentFilterConfig: null,
    };

    // 📦 CURRENT DATA (shared între modal și normal)
    this.injectedFilterDIV = false;
    this.currentSource = '';
    this.elementId = 'filterWindow';
    this.className = '.filter-window-content';

    // this.currentModalData = null;

    // State management - din panel
    this.panelContent = null;
    this.columnsList = null;
    this.searchInput = null;
    this.requestSource = null;
    this.activeElement = null;

    // 🎯 APLICĂ TOATE MIXINS
    Object.assign(this, filterUIMixin);
    Object.assign(this, filterSQLMixin);
    Object.assign(this, filterFormMixin);
    Object.assign(this, filterEventsHandlersMixin);
    Object.assign(this, filterEventsMixin);
    Object.assign(this, filterModalWindow);
    Object.assign(this, filterColumnsMixin);
    Object.assign(this, filterUtilsMixin);

    // 📊 CORE STATE
    this.isVisible = false;
    this.isInitialized = false;
    this.isModal = false;
    this.activeFilters = new Map(); // Centralizat în manager
    this.filterHistory = [];
    this.maxHistorySize = 50;

    this.areModalEventListenersSet = false;
    this.areBUSListenersSet = false;

    // 📈 PERFORMANCE METRICS
    this.metrics = {
      filtersApplied: 0,
      filtersCleared: 0,
      modalsOpened: 0,
      avgFilterTime: 0,
      lastFilterTime: 0,
      totalFilterTime: 0,
    };

    // Store singleton
    FilterManager.instance = this;

    // 🎯 AUTO-REGISTER în registry
    registerInstance('filterManager', this, {
      version: '4.0.0',
      description: 'Modular filter manager',
      features: ['filtering', 'modal', 'panel', 'sql-generation'],
      dependencies: ['eventBus', 'ListenerTracker'],
    });

    this.log('✅ FilterManager singleton creat');
  }

  /**
   * 🚀 INIȚIALIZARE COMPLETĂ
   */
  async init() {
    if (this.isInitialized) {
      this.log('⚠️ FilterManager deja inițializat');
      return true;
    }

    try {
      this.log('🚀 Inițializare FilterManager...');

      // Setup event listeners
      //this.setupBUSListeners();

      // Inițializare UI (din filter-ui.js mixin)
      await this.initializeUI();

      // Setup DOM listeners pentru modal
      this.setupModalEventListeners(this.modalElement);

      // Setup BUS listeners
      this.setupBUSListeners();

      // Actualizează toate vizualurile existente
      // this.updateAllFilterVisuals();

      this.isInitialized = true;
      this.log('✅ FilterManager inițializat cu succes');

      return true;
    } catch (error) {
      this.handleError('Eroare la inițializare FilterManager', error);
      return false;
    }
  }

  /**
   * ✅ APLICARE FILTRU
   */
  async applyFilter(filterData) {
    const startTime = performance.now();

    const currentFilterId = filterData.id;

    try {
      this.log(`✅ Aplicare filtru pentru: ${this.currentColumn.field}`, filterData);

      // Construiește otherFilters (exclude filtrul curent)
      filterData.otherFilters =
        this.activeFilters && this.activeFilters instanceof Map
          ? Array.from(this.activeFilters.values())
              .filter((v) => v && v.filterString && v.id !== currentFilterId)
              .map((v) => v.filterString)
              .join(' AND ')
          : '';

      // Emit eveniment pentru refresh tabel
      this.eventBus.emit(EVENTS.DATA_REFRESH_START, {
        reason: 'filter_applied',
        view: this.getInstance('tabs').currentView,
        sort: '',
        currentFilter: filterData.filterString,
        otherFilters: filterData.otherFilters,
        hideHidden: 1,
        columnId: this.currentColumn.id,
        timestamp: Date.now(),
      });

      // Așteaptă refresh completat
      try {
        const refreshResult = await this.eventBus.waitFor(EVENTS.DATA_REFRESH_COMPLETE);
        this.currentColumn.filterConfig = filterData;
        this.currentColumn.hasFilter = true;
        this.currentColumn.filter = filterData.filterString;

        this.currentFilter = filterData;
        this.log('🔄 Refresh completat după aplicarea filtrului:', refreshResult);
      } catch (e) {
        this.log('⚠️ Timeout la așteptarea refreshului');
      }

      // Salvează filtrul în state
      this.activeFilters.set(this.currentColumn.id, filterData);

      // Salvează filtrul și în coloană
      this.currentColumn.hasFilter = true;
      this.currentColumn.filter = filterData.filterString;
      this.currentColumn.filterConfig = filterData;

      // Închide modalul
      this.modalState.isOpen = false;

      // Emit evenimente
      this.eventBus.emit(EVENTS.FILTER_APPLIED, this.currentColumn);
      this.eventBus.emit(EVENTS.FILTER_CLOSE_WINDOW);

      // Tracking performance
      const filterTime = performance.now() - startTime;
      this.updateMetrics('filter_applied', filterTime);

      // Adaugă în istoric
      this.addToHistory({
        action: 'filter_applied',
        column: filterData.columnId,
        filterConfig: { ...filterData },
        executionTime: filterTime,
        timestamp: Date.now(),
      });

      this.log(`✅ Filtru aplicat cu succes în ${filterTime.toFixed(2)}ms`);
    } catch (error) {
      this.handleError('Eroare la aplicarea filtrului', error);

      this.eventBus.emit(EVENTS.FILTER_ERROR, {
        action: 'filter_apply',
        error: error.message,
        filterData,
        timestamp: Date.now(),
      });
    }
  }

  /**
   * 📈 METRICS & TRACKING
   */
  updateMetrics(action, executionTime = 0) {
    switch (action) {
      case 'filter_applied':
        this.metrics.filtersApplied++;
        this.metrics.lastFilterTime = executionTime;
        this.metrics.totalFilterTime += executionTime;
        this.metrics.avgFilterTime = this.metrics.totalFilterTime / this.metrics.filtersApplied;
        break;
      case 'filter_cleared':
        this.metrics.filtersCleared++;
        break;
      case 'modal_opened':
        this.metrics.modalsOpened++;
        break;
    }
  }

  addToHistory(historyItem) {
    this.filterHistory.push(historyItem);
    if (this.filterHistory.length > this.maxHistorySize) {
      this.filterHistory = this.filterHistory.slice(-this.maxHistorySize);
    }
  }

  /**
   * 📊 GETTERS
   */
  getState() {
    return {
      isInitialized: this.isInitialized,
      activeFiltersCount: this.activeFilters.size,
      modalState: this.getModalState(), // din filter-form.js
      metrics: { ...this.metrics },
      historyCount: this.filterHistory.length,
    };
  }

  /**
   * 🗑️ CLEANUP
   */
  destroy() {
    this.log('🗑️ Destrucție FilterManager...');

    // Cleanup listeners (automat prin ListenerTracker)
    const stats = this.cleanupAllListeners();

    // Clear state
    this.activeFilters.clear();
    this.filterHistory = [];
    this.isInitialized = false;

    // Reset metrics
    this.metrics = {
      filtersApplied: 0,
      filtersCleared: 0,
      modalsOpened: 0,
      avgFilterTime: 0,
      lastFilterTime: 0,
      totalFilterTime: 0,
    };

    // Reset singleton
    FilterManager.instance = null;

    this.log(`✅ FilterManager distrus complet`, stats);
  }

  /**
   * 🛠 ERROR HANDLING & LOGGING
   */
  handleError(message, error) {
    this.log.error(`❌ ${message}`, error);

    eventBus.emit(EVENTS.ERROR_OCCURRED, {
      source: 'FilterManager',
      message,
      error: error?.message || error,
      timestamp: Date.now(),
    });
  }

  /**
   * 📊 LOGGER
   */
  log = (() => {
    const fn = (message, data = null) => {
      if (this.debugMode) {
        const now = new Date();
        const ts = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now
          .getMilliseconds()
          .toString()
          .padStart(3, '0')}`;
        const CPN = 'FilterManager'.padEnd(15);
        console.log(
          `%c[${ts}] [${CPN}] ${message}`,
          'color: #763cfdff; font-weight: bold;',
          data ?? ''
        );
      }
    };

    fn.error = (message, data = null) => {
      const now = new Date();
      const ts = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now
        .getMilliseconds()
        .toString()
        .padStart(3, '0')}`;
      const CPN = 'FilterManager'.padEnd(15);
      console.error(
        `%c[${ts}] [${CPN}] ${message}`,
        'color: #ff3333; font-weight: bold;',
        data ?? ''
      );
    };

    return fn;
  })();
}

// Creare și export instanță singleton
const filterManager = new FilterManager();
export default filterManager;
