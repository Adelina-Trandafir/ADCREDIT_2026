// File: static/js/table-controller/table-controller-data.js
/**
 * 📡 TABLE CONTROLLER DATA MIXIN
 * Gestionează orchestrarea încărcării datelor
 *
 * RESPONSABILITĂȚI:
 * ✅ Solicită încărcarea datelor (NU încarcă direct!)
 * ✅ Gestionează răspunsurile de la data loader
 * ✅ Promise-based data loading
 * ✅ Timeout handling
 * ✅ Performance tracking
 *
 * @version 1.0.0
 */

export const tableControllerDataMixin = {
  /**
   * 📡 SOLICITĂ ÎNCĂRCAREA DATELOR - NU ÎNCARCĂ DIRECT!
   * Returnează o Promise care se rezolvă când datele sunt încărcate
   */
  requestDataLoad(options = {}) {
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        this.log('⏰ Timeout waiting for data load response');
        resolve(null);
      }, 10000); // 10 secunde

      const successHandler = (eventData) => {
        clearTimeout(timeout);
        this.eventBus.off(this.EVENTS.DATA_LOAD_COMPLETE, successHandler);
        this.eventBus.off(this.EVENTS.DATA_LOAD_ERROR, errorHandler);
        this.eventBus.off(this.EVENTS.DATA_LOAD_SKIPPED, skippedHandler);
        resolve(eventData);
      };

      const errorHandler = (eventData) => {
        clearTimeout(timeout);
        this.eventBus.off(this.EVENTS.DATA_LOAD_COMPLETE, successHandler);
        this.eventBus.off(this.EVENTS.DATA_LOAD_ERROR, errorHandler);
        this.eventBus.off(this.EVENTS.DATA_LOAD_SKIPPED, skippedHandler);
        reject(eventData.error);
      };

      const skippedHandler = (eventData) => {
        clearTimeout(timeout);
        this.eventBus.off(this.EVENTS.DATA_LOAD_COMPLETE, successHandler);
        this.eventBus.off(this.EVENTS.DATA_LOAD_ERROR, errorHandler);
        this.eventBus.off(this.EVENTS.DATA_LOAD_SKIPPED, skippedHandler);
        this.log('📌 Încărcare skipped:', eventData.message);
        resolve(null);
      };

      this.eventBus.on(this.EVENTS.DATA_LOAD_COMPLETE, successHandler);
      this.eventBus.on(this.EVENTS.DATA_LOAD_ERROR, errorHandler);
      this.eventBus.on(this.EVENTS.DATA_LOAD_SKIPPED, skippedHandler);

      // Emit evenimentul pentru încărcarea datelor
      // ⚠️ DOAR DE TESTE - maxRecords = 20
      // Schimbă în producție pentru toate înregistrările
      this.eventBus.emit(this.EVENTS.DATA_LOAD_START, {
        reason: 'table_load',
        view: this.getInstance('tabs').currentView,
        maxRecords: 20, // TODO: Schimbă în producție
        sort: '',
        currentFilter: '',
        otherFilters: '',
        hideHidden: 0,
        timestamp: Date.now(),
      });

      this.log('📡 Cerere încărcare date emisă', {
        view: options.view || this.getInstance('tabs').currentView,
        maxRecords: 20,
      });
    });
  },

  /**
   * 📥 GESTIONEAZĂ DATELE ÎNCĂRCATE - DOAR actualizează starea
   */
  handleTableBuildComplete(eventData) {
    try {
      const { timestamp } = eventData.data;
      const processingTime = Date.now() - timestamp;

      this.log('📥 Tabelul a fost construit cu succes in:', {
        processingTime,
      });

      this.lastContainerHeight = eventData.data.currentWindowSize.height || 0;
      this.lastContainerWidth = eventData.data.currentWindowSize.width || 0;

      // Setup container resize (din lifecycle mixin)
      this.setupContainerResize();

      // Track performance
      this.performanceMetrics.lastLoadTime = processingTime || 0;
      this.performanceMetrics.totalLoads++;
    } catch (error) {
      this.handleError('Eroare la procesarea confirmării datelor', error);
    }
  },

  /**
   * ❌ GESTIONEAZĂ ERORILE DE ÎNCĂRCARE
   */
  handleDataError(eventData) {
    const error = eventData.error || 'Eroare necunoscută';
    this.log('❌ Eroare raportată de data-loader:', error);

    this.eventBus.emit(this.EVENTS.ERROR_OCCURRED, {
      type: 'data-load',
      message: error,
      timestamp: Date.now(),
    });
  },
};
