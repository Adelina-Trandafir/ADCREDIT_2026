// File: static/js/dashboard/data-loader.js (UPDATED cu SessionData)
/**
 * 📡 DATA LOADER - CU LISTENER TRACKING AUTOMAT + SESSION DATA
 */

//import '../global-variables.js';

import eventBus, { EVENTS } from '../event-bus/event-bus.js';
import { getInstance, registerInstance } from '../instances-registry.js';
import ListenerTracker from '../listener-tracker/listener-tracker-mixin.js';

class DataLoader {
  constructor() {
    // Singleton check
    if (DataLoader.instance) {
      console.warn('⚠️ DataLoader is singleton, returning existing instance');
      return DataLoader.instance;
    }

    this.debugMode = false;

    // 🎯 APLICĂ MIXIN-UL LISTENER TRACKER
    ListenerTracker.applyTo(this, {
      debugMode: this.debugMode || false,
      logPrefix: 'DataLoader',
      trackPerformance: true,
    });

    this.isLoading = false;
    this.currentRequest = null;
    this.cache = new Map();
    this.maxCacheSize = 10;

    this.metrics = {
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      avgLoadTime: 0,
      cacheHits: 0,
    };

    this.rowsData = [];
    this.columnsData = [];
    this.allRights = [];
    this.statsData = {};
    this.rights = {};
    // this.allData = {};
    this.allColumns = [];
    //this.department = '';

    // Store singleton instance
    DataLoader.instance = this;

    // 🎯 AUTO-REGISTER în registry
    registerInstance('dataLoader', this, {
      version: '3.0.0',
      description: 'Main data loader for dashboard',
      features: ['data-loading', 'caching', 'event-driven', 'session-data'],
      dependencies: ['sessionData'],
    });
  }

  // Functie care obtine toate datele daca nu primeste niciun parametru,
  // altfel obtine datele pentru un anumit ID si coloana
  async allData(searchId, searchColumn) {
    let response;

    try {
      if (searchId && searchColumn) {
        response = await fetch('/api/get-cached-data', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            type: 'all_data',
            searchId: searchId,
            searchColumn: searchColumn,
          }),
        });
      } else {
        response = await fetch('/api/get-cached-data', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ type: 'all_data' }),
        });
      }

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      // Testez mai intai daca raspunsul este JSON, sau string simplu
      const contentType = response.headers.get('Content-Type');
      let data;
      if (contentType && contentType.includes('application/json')) {
        data = await response.json();
        this.log('✅ Date obținute:', data);
      } else {
        this.log.error('⚠️ Răspuns invalid de la server:', await response.text());
      }

      return data.data;
    } catch (error) {
      console.error('⚠️ Eroare la obținerea datelor:', error);
      return null;
    }
  }

  /**
   * 🚀 INIȚIALIZARE
   */
  init() {
    this.setupEventListeners();
    this.log('📡 DataLoader inițializat cu succes');
    return true;
  }

  /**
   * 📡 SETUP EVENT LISTENERS
   */
  setupEventListeners() {
    this.addBusListener(EVENTS.DATA_LOAD_START, (eventData) => this.handleLoadRequest(eventData));
    this.addBusListener(EVENTS.DATA_REFRESH_START, (eventData) =>
      this.handleRefreshRequest(eventData)
    );
    this.log('📡 Event listeners configurați cu tracking automat');
  }

  /**
   * 📞 HANDLER PENTRU CERERI DE ÎNCĂRCARE
   */
  async handleLoadRequest(payload) {
    try {
      await this.loadData(payload);
    } catch (error) {
      this.log.error('⚠️ Eroare la încărcare', error);
    }
  }

  /**
   * 📡 ÎNCĂRCARE
   */
  async loadData(options = {}) {
    if (this.isLoading) {
      this.log('⚠️ Încărcare deja în progres');
      eventBus.emit(EVENTS.DATA_LOAD_SKIPPED, { message: 'Skipped', payload: options });
      return Promise.resolve(null);
    }

    this.isLoading = true;
    const startTime = performance.now();
    const loadingElement = document.getElementById('loading');

    try {
      // Afișează loader
      if (loadingElement) loadingElement.style.display = 'flex';

      // Ascunde tabelul temporar
      const dataTable = document.getElementById('dataTable');
      if (dataTable) dataTable.style.display = 'none';

      // Construiește payload
      const payload = this.buildPayload(options);
      this.log('📤 Încărcare date cu payload:', payload);
      this.metrics.totalRequests++;

      // Request către server
      const response = await fetch('/api/dashboard-data', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      const loadTime = performance.now() - startTime;

      if (data.success) {
        data.reason = 'Load';
        this.metrics.successfulRequests++;
        this.updateLoadTimeAverage(loadTime);

        // Procesează și emit succes
        this.processLoadSuccessfulData(data, loadTime);

        return data;
      } else {
        this.metrics.failedRequests++;
        throw new Error(data.message || data.error || 'Eroare la server');
      }
    } catch (error) {
      this.metrics.failedRequests++;
      this.emitError(error);
      throw error;
    } finally {
      this.isLoading = false;

      // Restaurează UI
      if (loadingElement) loadingElement.style.display = 'none';
      const dataTable = document.getElementById('dataTable');
      if (dataTable) dataTable.style.display = 'table';
    }
  }

  /**
   * 📊 PROCESEAZĂ DATELE DE SUCCES (UPDATED - folosește SessionData)
   */
  processLoadSuccessfulData(responseData, loadTime) {
    const { rowsData, columnsData, statsData, rights } = responseData;

    if (responseData.reason == 'Load') {
      this.log('✅ Date procesate:', {
        rows: rowsData?.length || 0,
        columns: columnsData?.length || 0,
        stats: statsData?.length || 0,
      });

      this.rowsData = rowsData || [];
      this.columnsData = columnsData || [];
      this.statsData = statsData || {};
      this.allRights = rights || [];
      // this.allData = responseData.allData || {};
      this.allColumns = responseData.allColumns || [];
      // this.department = responseData.department;

      const simplifiedRights = {};
      rights.forEach((right) => {
        simplifiedRights[right.id_drept] = right.valoare;
      });

      this.rights = simplifiedRights;
    } else {
      this.log.error(
        `❌ Motiv incorect pentru functia processLoadSuccessfulData ${responseData.reason}`
      );
    }

    // Emit evenimente către alte module
    eventBus.emit(EVENTS.DATA_LOAD_COMPLETE, {
      rowsData: rowsData,
      columnsData: columnsData,
      statsData: statsData,
      processingTime: loadTime,
      timestamp: Date.now(),
      reason: responseData.reason,
    });

    eventBus.emit(EVENTS.STATS_UPDATE, responseData.statsData);

    // Log pentru performance
    if (responseData.processing_time) {
      this.log(`⚡ Timp server: ${responseData.processing_time.toFixed(2)}ms`);
    }
    if (loadTime) {
      this.log(`⚡ Timp total: ${loadTime.toFixed(2)}ms`);
    }
  }

  /**
   * 📞 HANDLER PENTRU CERERI DE REFRESH
   */
  async handleRefreshRequest(payload) {
    try {
      await this.refreshData(payload);
    } catch (error) {
      this.log.error('⚠️ Refresh rapid eșuat', error);
    }
  }

  /**
   * 🔄 REFRESH
   */
  async refreshData(options = {}) {
    if (this.isLoading) {
      this.log('⚠️ Încărcare deja în progres');
      eventBus.emit(EVENTS.DATA_LOAD_SKIPPED, { message: 'Skipped', payload: options });
      return Promise.resolve(null);
    }

    this.isLoading = true;
    const startTime = performance.now();

    try {
      // Construiește payload
      const payload = this.buildPayload(options);
      this.log('📤 Refresh date cu payload:', payload);
      this.metrics.totalRequests++;

      // Request către server
      const response = await fetch('/api/dashboard-data-quick', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      const loadTime = performance.now() - startTime;

      if (data.success) {
        data.reason = options?.data?.reason || 'Refresh';
        data.columnId = options?.data?.columnId || null;
        this.metrics.successfulRequests++;
        this.updateLoadTimeAverage(loadTime);

        // Procesează și emit succes
        this.processRefreshSuccessfulData(data, loadTime);

        return data;
      } else {
        this.metrics.failedRequests++;
        throw new Error(data.message || data.error || 'Eroare la server');
      }
    } catch (error) {
      this.metrics.failedRequests++;
      this.emitError(error);
      throw error;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 📊 PROCESEAZĂ REFRESH RAPID (UPDATED - folosește SessionData)
   */
  processRefreshSuccessfulData(responseData, loadTime) {
    const { rowsData, statsData } = responseData;

    this.rowsData = rowsData || [];
    this.statsData = statsData || {};

    this.log('✅ Date refresh procesate:', {
      rows: rowsData?.length || 0,
      preserveColumns: true,
    });

    eventBus.emit(EVENTS.STATS_UPDATE, statsData);

    // Emit evenimente pentru refresh
    eventBus.emit(EVENTS.DATA_REFRESH_COMPLETE, {
      processingTime: loadTime,
      timestamp: Date.now(),
      reason: responseData.reason,
      columnId: responseData.columnId,
      newRowsData: rowsData,
    });

    // Log pentru performance
    if (responseData.processing_time) {
      this.log(`⚡ Timp server: ${responseData.processing_time.toFixed(2)}ms`);
    }
    if (loadTime) {
      this.log(`⚡ Timp total refresh: ${loadTime.toFixed(2)}ms`);
    }
  }

  /**
   * Handler pentru obținerea coloanelor din chache
   * @returns {Promise<Array>} Lista de coloane
   * @throws {Error} Dacă apare o eroare la obținerea coloanelor
   */
  async handleGetAllColumns() {
    try {
      const response = await fetch('/api/all-columns-chached', {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' },
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      this.log('✅ Coloane obținute:', data);
      return data;
    } catch (error) {
      this.log.error('⚠️ Eroare la obținerea coloanelor', error);
    }
  }

  /**
   * 🔧 CONSTRUIEȘTE PAYLOAD PENTRU API
   */
  buildPayload(options = {}) {
    const { view, sort, currentFilter, otherFilters } = options.data;

    return {
      view: view,
      filtru:
        currentFilter && otherFilters
          ? `${currentFilter} AND ${otherFilters}`
          : currentFilter || otherFilters,
      sort: sort,
      maxRecords: options.data.maxRecords || '200',
      idCautat: options.data.idCautat || 0,
    };
  }

  /**
   * 📤 EMIT EROARE
   */
  emitError(error) {
    const errorMessage = error.message || 'Eroare necunoscută';
    this.log('❌ Emit eroare:', errorMessage);

    eventBus.emit(EVENTS.DATA_LOAD_ERROR, {
      error: errorMessage,
      type: error.type || 'network',
      timestamp: Date.now(),
    });
  }

  /**
   * 💾 CACHE MANAGEMENT
   */
  generateCacheKey(options) {
    const view = options.view;
    return `${view}_${JSON.stringify(options)}`;
  }

  saveToCache(key, data) {
    if (this.cache.size >= this.maxCacheSize) {
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }

    this.cache.set(key, {
      data,
      timestamp: Date.now(),
    });
  }

  /**
   * 📈 PERFORMANCE METRICS
   */
  updateLoadTimeAverage(loadTime) {
    if (this.metrics.successfulRequests === 1) {
      this.metrics.avgLoadTime = loadTime;
    } else {
      this.metrics.avgLoadTime =
        (this.metrics.avgLoadTime * (this.metrics.successfulRequests - 1) + loadTime) /
        this.metrics.successfulRequests;
    }
  }

  getMetrics() {
    return {
      ...this.metrics,
      cacheSize: this.cache.size,
      isLoading: this.isLoading,
    };
  }

  /**
   * 🐛 ERROR HANDLING
   */
  handleError(message, error) {
    this.log.error(`❌ DataLoader: ${message}`, error);
    this.emitError(error);
  }

  /**
   * 📝 LOG
   */
  log = (() => {
    const fn = (message, data = null) => {
      if (this.debugMode) {
        const now = new Date();
        const ts = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now
          .getMilliseconds()
          .toString()
          .padStart(3, '0')}`;
        const CPN = 'DataLoader'.padEnd(15);
        console.log(
          `%c[${ts}] [${CPN}] ${message}`,
          'color: #3b82f6; font-weight: bold;',
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
      const CPN = 'DataLoader'.padEnd(15);
      console.error(
        `%c[${ts}] [${CPN}] ${message}`,
        'color: #ff3333; font-weight: bold;',
        data ?? ''
      );
    };

    return fn;
  })();

  /**
   * 🗑️ DESTROY
   */
  destroy() {
    this.log('🗑️ Începe distrugerea DataLoader...');

    // Cleanup automat al tuturor listeners
    const cleanupStats = this.cleanupAllListeners();

    // Curăță cache
    this.cache.clear();

    // Reset state
    this.isLoading = false;
    this.currentRequest = null;

    // 🎯 RESET SINGLETON
    DataLoader.instance = null;

    this.log('✅ DataLoader distrus complet', cleanupStats);
  }
}

// Creează instanța globală
const dataLoader = new DataLoader();

// Export pentru module
export default dataLoader;
