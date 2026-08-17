// File: static/js/table-controller/table-controller-manager.js
/**
 * 🎯 TABLE CONTROLLER MANAGER - Main Orchestrator
 *
 * RESPONSABILITĂȚI:
 * ✅ Singleton pattern
 * ✅ Orchestrează comunicarea între module
 * ✅ Menține starea aplicației
 * ✅ Coordonează acțiunile utilizatorului
 * ✅ NU face request-uri HTTP direct
 *
 * @version 3.0.0
 * @author Adelina Trandafir - Avatar Soft SRL
 */

//import '../../global-variables.js';
import eventBus, { EVENTS } from '../../event-bus/event-bus.js';
import ListenerTracker from '../../listener-tracker/listener-tracker-mixin.js';
import { getInstance, registerInstance } from '../../instances-registry.js';

// 🎯 IMPORT MIXINS
import { tableControllerStateMixin } from './table-controller-state.js';
import { tableControllerDataMixin } from './table-controller-data.js';
import { tableControllerEventsMixin } from './table-controller-events.js';
import { tableControllerLifecycleMixin } from './table-controller-lifecycle.js';

class TableController {
  constructor() {
    // Singleton check
    if (TableController.instance) {
      this.log.error('⚠️ TableController is singleton, returning existing instance');
      return TableController.instance;
    }

    this.debugMode = true;
    TableController.instance = this;

    // 🎯 APLICĂ MIXIN-UL LISTENER TRACKER
    ListenerTracker.applyTo(this, {
      debugMode: this.debugMode || false,
      logPrefix: 'TableController',
      trackPerformance: true,
    });

    this.eventBus = eventBus;
    this.EVENTS = EVENTS;
    this.getInstance = getInstance;

    // 🎯 APPLY MIXINS
    Object.assign(this, tableControllerStateMixin);
    Object.assign(this, tableControllerDataMixin);
    Object.assign(this, tableControllerEventsMixin);
    Object.assign(this, tableControllerLifecycleMixin);

    // 🎯 STATE PRINCIPAL
    this.isInitialized = false;
    this.currentState = {
      view: null,
      filters: {},
      sort: null,
      selectedRows: new Set(),
      multiSelectMode: false,
    };

    // 📈 PERFORMANCE METRICS
    this.performanceMetrics = {
      lastLoadTime: 0,
      lastBuildTime: 0,
      totalLoads: 0,
      totalBuilds: 0,
    };

    // 🔍 OBSERVATOR PENTRU REDIMENSIONARE
    this.resizeObserver = null;
    this.lastContainerWidth = 0;
    this.lastContainerHeight = 0;

    // 🎯 AUTO-REGISTER în registry
    registerInstance('tableController', this, {
      version: '3.0.0',
      description: 'Main table controller with modular mixins',
      features: ['state', 'data-loading', 'events', 'lifecycle'],
    });
  }

  /**
   * 🚀 INIȚIALIZARE - API public (compatibilitate)
   * Logica internă în lifecycle mixin
   */
  async init(options = {}) {
    if (this.isInitialized) {
      this.log('⚠️ TableController deja inițializat');
      return true;
    }

    try {
      this.options = {
        view: options.view,
        autoLoad: options.autoLoad !== false,
      };

      // Setup event listeners (din events mixin)
      this.setupEventListeners();

      // Dacă autoLoad e activat, solicită încărcarea datelor (din data mixin)
      if (this.options.autoLoad) {
        await this.requestDataLoad({ view: this.options.view });
      }

      this.isInitialized = true;
      this.log('✅ TableController inițializat complet');

      eventBus.emit(EVENTS.TABLE_MANAGER_READY, {
        isInitialized: true,
        timestamp: Date.now(),
      });

      this.log('📡 TableController inițializat cu succes');

      return true;
    } catch (error) {
      this.handleError('Eroare la inițializarea TableController', error);
      return false;
    }
  }

  /**
   * 🔄 REBUILD - API public (compatibilitate)
   * Logica internă în lifecycle mixin
   */
  async rebuild(options = {}) {
    this.log('🔨 Rebuild complet solicitat...');

    if (!this.isInitialized) {
      this.log('⚠️ TableController nu e inițializat');
      return;
    }

    // Resetează selecțiile (din state mixin)
    this.clearSelections();

    try {
      await this.requestDataLoad(options);
      this.log('✅ Rebuild completat');
    } catch (error) {
      this.handleError('Eroare la rebuild', error);
    }
  }

  /**
   * 📊 GET STATE - API public (compatibilitate)
   */
  getState() {
    return {
      isInitialized: this.isInitialized,
      currentView: this.currentState.view,
      activeFilters: Object.keys(this.currentState.filters).length,
      selectedRows: this.currentState.selectedRows.size,
      multiSelectMode: this.currentState.multiSelectMode,
      hasSort: !!this.currentState.sort,
    };
  }

  /**
   * 📊 GET PERFORMANCE STATS - API public
   */
  getPerformanceStats() {
    const avgLoadTime =
      this.performanceMetrics.totalLoads > 0
        ? (this.performanceMetrics.lastLoadTime / this.performanceMetrics.totalLoads).toFixed(2)
        : 0;

    const avgBuildTime =
      this.performanceMetrics.totalBuilds > 0
        ? (this.performanceMetrics.lastBuildTime / this.performanceMetrics.totalBuilds).toFixed(2)
        : 0;

    return {
      totalLoads: this.performanceMetrics.totalLoads,
      totalBuilds: this.performanceMetrics.totalBuilds,
      lastLoadTime: this.performanceMetrics.lastLoadTime,
      lastBuildTime: this.performanceMetrics.lastBuildTime,
      avgLoadTime,
      avgBuildTime,
    };
  }

  /**
   * 🗑️ DESTROY - API public (compatibilitate)
   * Logica internă în lifecycle mixin
   */
  destroy() {
    this.log('🗑️ Destrucție TableController...');

    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
      this.log('🧹 ResizeObserver deconectat');
    }

    // 🧹 CLEANUP AUTOMAT PRIN MIXIN
    const cleanupStats = this.cleanupAllListeners();
    this.log('🧹 Cleanup automat complet:', cleanupStats);

    // Reset state (din state mixin)
    this.resetState();

    this.isInitialized = false;

    // 🎯 RESET SINGLETON
    TableController.instance = null;

    this.log('✅ TableController distrus');
  }

  /**
   * 🛑 GESTIONEAZĂ ERORILE
   */
  handleError(message, error) {
    this.log.error(`❌ TableController: ${message}`, error);

    eventBus.emit(EVENTS.ERROR_OCCURRED, {
      source: 'TableController',
      message,
      error: error.message || error,
      timestamp: Date.now(),
    });
  }

  /**
   * 📊 LOG pentru debugging
   */
  log = (() => {
    const fn = (message, data = null) => {
      if (this.debugMode) {
        const now = new Date();
        const ts = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now
          .getMilliseconds()
          .toString()
          .padStart(3, '0')}`;
        const CPN = 'TableController'.padEnd(15);
        console.log(
          `%c[${ts}] [${CPN}] ${message}`,
          'color: #10b981; font-weight: bold;',
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
      const CPN = 'TableController'.padEnd(15);
      console.error(
        `%c[${ts}] [${CPN}] ${message}`,
        'color: #ff3333; font-weight: bold;',
        data ?? ''
      );
    };

    return fn;
  })(this);
}

// Creează instanța globală
const tableController = new TableController();

// Export pentru module
export default tableController;
