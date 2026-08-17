// File: static/js/dashboard/data-loader.js (UPDATED cu SessionData + QUEUE simplificat)
/**
 * 📡 EXTRA DATA LOADER - CU LISTENER TRACKING AUTOMAT + SESSION DATA + QUEUE
 */

//import '../global-variables.js';

import eventBus, { EVENTS } from '../event-bus/event-bus.js';
import { registerInstance } from '../instances-registry.js';
import ListenerTracker from '../listener-tracker/listener-tracker-mixin.js';

class DataLoaderExtra {
  constructor() {
    // Singleton check
    if (DataLoaderExtra.instance) {
      console.warn('⚠️ DataLoaderExtra is singleton, returning existing instance');
      return DataLoaderExtra.instance;
    }

    this.debugMode = false;

    // 🎯 APLICĂ MIXIN-UL LISTENER TRACKER
    ListenerTracker.applyTo(this, {
      debugMode: this.debugMode || false,
      logPrefix: 'DataLoaderExtra',
      trackPerformance: true,
    });

    this.isLoading = false;
    this.currentRequest = null;
    this.cache = new Map();
    this.maxCacheSize = 10;

    // 🔄 QUEUE PENTRU CERERI ÎN AȘTEPTARE
    this.requestQueue = [];
    this.isProcessingQueue = false;

    this.metrics = {
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      avgLoadTime: 0,
      cacheHits: 0,
    };

    // Store singleton instance
    DataLoaderExtra.instance = this;

    // 🎯 AUTO-REGISTER în registry
    registerInstance('dataLoaderExtra', this, {
      version: '3.1.0',
      description: 'Data loader for coresponding tables with request queue',
      features: ['data-loading', 'caching', 'event-driven', 'session-data', 'request-queue'],
      dependencies: ['sessionData'],
    });
  }

  /**
   * 🚀 INIȚIALIZARE
   */
  init() {
    this.setupEventListeners();
    this.log('📡 DataLoaderExtra inițializat cu succes (cu queue)');
    return true;
  }

  /**
   * 📡 SETUP EVENT LISTENERS
   */
  setupEventListeners() {
    this.addBusListener(EVENTS.EXTRA_DATA_LOAD_START, (eventData) =>
      this.handleExtraLoadRequest(eventData)
    );
    this.addBusListener(EVENTS.EXTRA_DATA_REFRESH_START, (eventData) =>
      this.handleExtraRefreshRequest(eventData)
    );
    this.addBusListener(EVENTS.EXTRA_DATA_SEARCH_START, (eventData) =>
      this.handleExtraSearchRequest(eventData)
    );
    this.log('📡 Event listeners configurați cu tracking automat');
  }

  /**
   * 📞 HANDLER PENTRU CERERI DE ÎNCĂRCARE
   */
  async handleExtraLoadRequest(eventData) {
    try {
      await this.loadData(eventData);
    } catch (error) {
      this.log.error('⚠️ Eroare la încărcare', error);
    }
  }

  /**
   * 📞 HANDLER PENTRU CERERI DE REFRESH
   */
  async handleExtraRefreshRequest(eventData) {
    try {
      await this.refreshData(eventData);
    } catch (error) {
      this.log.error('⚠️ Eroare la refresh', error);
    }
  }

  /**
   * 📞 HANDLER PENTRU CERERI DE CĂUTARE
   */
  async handleExtraSearchRequest(eventData) {
    try {
      await this.searchData(eventData);
    } catch (error) {
      this.log.error('⚠️ Eroare la încărcare', error);
    }
  }

  /**
   * 📡 ÎNCĂRCARE CU QUEUE MANAGEMENT
   */
  async loadData(eventData) {
    // Dacă există deja o încărcare în progres, adaugă cererea în coadă
    if (this.isLoading) {
      this.log('⚠️ Încărcare deja în progres - adăugare în coadă');
      return this.addToQueue(eventData, 'load');
    }

    return this.executeLoadRequest(eventData);
  }

  /**
   * 🔄 REFRESH CU QUEUE MANAGEMENT
   */
  async refreshData(eventData) {
    // Dacă există deja o încărcare în progres, adaugă cererea în coadă
    if (this.isLoading) {
      this.log('⚠️ Refresh deja în progres - adăugare în coadă');
      return this.addToQueue(eventData, 'refresh');
    }

    return this.executeRefreshRequest(eventData);
  }

  /**
   * 🔍 CĂUTARE CU QUEUE MANAGEMENT
   */
  async searchData(eventData) {
    // Dacă există deja o căutare în progres, adaugă cererea în coadă
    if (this.isLoading) {
      this.log('⚠️ Căutare deja în progres - adăugare în coadă');
      return this.addToQueue(eventData, 'search');
    }
    return this.executeSearchRequest(eventData);
  }

  /**
   * ➕ ADAUGĂ CERERE ÎN COADĂ
   */
  addToQueue(eventData, requestType) {
    return new Promise((resolve, reject) => {
      const queueItem = {
        eventData,
        requestType,
        resolve,
        reject,
        timestamp: Date.now(),
      };

      this.requestQueue.push(queueItem);
      this.log(`📋 Cerere adăugată în coadă (total: ${this.requestQueue.length})`);
    });
  }

  /**
   * 🔄 PROCESEAZĂ COADA DE CERERI
   */
  async processQueue() {
    if (this.isProcessingQueue || this.requestQueue.length === 0) {
      return;
    }

    this.isProcessingQueue = true;
    this.log(`📋 Începe procesarea cozii (${this.requestQueue.length} cereri)`);

    while (this.requestQueue.length > 0) {
      const queueItem = this.requestQueue.shift();

      try {
        let result;
        if (queueItem.requestType === 'load') {
          result = await this.executeLoadRequest(queueItem.eventData);
        } else if (queueItem.requestType === 'refresh') {
          result = await this.executeRefreshRequest(queueItem.eventData);
        } else if (queueItem.requestType === 'search') {
          result = await this.executeSearchRequest(queueItem.eventData);
        }

        queueItem.resolve(result);
      } catch (error) {
        this.log.error(`❌ Eroare la procesarea cererii din coadă`, error);
        queueItem.reject(error);
      }
    }

    this.isProcessingQueue = false;
    this.log('📋 Procesarea cozii finalizată');
  }

  /**
   * 🚀 EXECUTĂ CERERE DE ÎNCĂRCARE
   */
  async executeLoadRequest(eventData) {
    this.isLoading = true;
    const startTime = performance.now();

    try {
      this.log('📤 Încărcare date pentru:', eventData);
      this.metrics.totalRequests++;

      // Request către server
      const response = await fetch('/api/get-extra-data', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(eventData),
      });

      if (!response.ok) {
        this.log.error(`HTTP error for: ${eventData.data.endpoint} status: ${response.status}`);
        return null;
      }

      const data = await response.json();
      const loadTime = performance.now() - startTime;

      if (data.success) {
        data.reason = 'Load';
        this.metrics.successfulRequests++;
        this.updateLoadTimeAverage(loadTime);

        this.log(`✅ Încărcare finalizată în ${loadTime.toFixed(2)}ms`);

        // 🎯 EMIT EVENIMENT CU DATELE ÎNCĂRCATE
        eventBus.emit(EVENTS.EXTRA_DATA_LOAD_COMPLETE, {
          receivedData: data,
          requestType: eventData.requestType,
          originalRequest: eventData,
          loadTime: loadTime,
          timestamp: Date.now(),
        });

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
      // După finalizarea cererii curente, procesează coada
      this.processQueue();
    }
  }

  /**
   * 🔄 EXECUTĂ CERERE DE REFRESH
   */
  async executeRefreshRequest(eventData) {
    this.isLoading = true;
    const startTime = performance.now();

    try {
      this.log('🔄 Refresh date pentru:', eventData);
      this.metrics.totalRequests++;

      // Request către server
      const response = await fetch('/api/extra-dashboard-data-quick', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(eventData),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      const loadTime = performance.now() - startTime;

      if (data.success) {
        data.reason = 'Refresh';
        this.metrics.successfulRequests++;
        this.updateLoadTimeAverage(loadTime);

        this.log(`✅ Refresh finalizat în ${loadTime.toFixed(2)}ms`);

        // 🎯 EMIT EVENIMENT CU DATELE REFRESH-ATE
        eventBus.emit(EVENTS.EXTRA_DATA_REFRESH_COMPLETE, {
          receivedData: data,
          requestType: eventData.requestType,
          originalRequest: eventData,
          loadTime: loadTime,
          timestamp: Date.now(),
        });

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
      // După finalizarea cererii curente, procesează coada
      this.processQueue();
    }
  }

  /**
   * 🚀 EXECUTĂ CERERE DE CĂUTARE
   */
  async executeSearchRequest(eventData) {
    this.isLoading = true;
    const startTime = performance.now();

    try {
      this.log('📤 Căutare date pentru:', eventData);
      this.metrics.totalRequests++;

      // Request către server
      const response = await fetch('/api/get-extra-data', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(eventData),
      });

      if (!response.ok) {
        this.log.error(`HTTP error for: ${eventData.data.endpoint} status: ${response.status}`);
        return null;
      }

      const data = await response.json();
      const loadTime = performance.now() - startTime;

      if (data.success) {
        data.reason = 'Search';
        this.metrics.successfulRequests++;
        this.updateLoadTimeAverage(loadTime);

        this.log(`✅ Căutare finalizată în ${loadTime.toFixed(2)}ms`);

        // 🎯 EMIT EVENIMENT CU DATELE ÎNCĂRCATE
        eventBus.emit(EVENTS.EXTRA_DATA_SEARCH_COMPLETE, {
          receivedData: data,
          requestType: eventData.requestType,
          originalRequest: eventData,
          loadTime: loadTime,
          timestamp: Date.now(),
        });

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
      // După finalizarea cererii curente, procesează coada
      this.processQueue();
    }
  }

  /**
   * 📤 EMIT EROARE
   */
  emitError(error) {
    const errorMessage = error.message || 'Eroare necunoscută';
    this.log('❌ Emit eroare:', errorMessage);

    eventBus.emit(EVENTS.EXTRA_DATA_ERROR, {
      error: errorMessage,
      type: error.type || 'network',
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

  /**
   * 📊 OBȚINE METRICS
   */
  getMetrics() {
    return {
      ...this.metrics,
      cacheSize: this.cache.size,
      isLoading: this.isLoading,
      queueLength: this.requestQueue.length,
    };
  }

  /**
   * 📝 LOG
   */
  log = (() => {
    const fn = (message, data = null) => {
      if (window.debugMode) {
        const now = new Date();
        const ts = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now
          .getMilliseconds()
          .toString()
          .padStart(3, '0')}`;
        const CPN = 'DataLoaderExtra'.padEnd(15);
        console.log(
          `%c[${ts}] [${CPN}] ${message}`,
          'color: #9333ea; font-weight: bold;',
          data ?? ''
        );
      }
    };

    fn.error = (message, error = null) => {
      const now = new Date();
      const ts = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now
        .getMilliseconds()
        .toString()
        .padStart(3, '0')}`;
      const CPN = 'DataLoaderExtra'.padEnd(15);
      console.error(
        `%c[${ts}] [${CPN}] ${message}`,
        'color: #dc2626; font-weight: bold;',
        error ?? ''
      );
    };

    return fn;
  })();
}

// Creează instanța globală
const dataLoaderExtra = new DataLoaderExtra();

// Export pentru module
export default dataLoaderExtra;
