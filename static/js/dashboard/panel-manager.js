/**
 * ========== PANEL MANAGER - Manager pentru Panele Suplimentare ==========
 * Gestionează afișarea/ascunderea panelelor suplimentare
 *
 * REFACTORIZAT CU:
 * ✅ Event-bus pentru comunicare între module
 * ✅ ListenerTracker pentru cleanup automat
 * ✅ Singleton pattern îmbunătățit
 */
/** * @module PanelManager
 * @version 3.1.0
 */

//import '../global-variables.js';
import eventBus, { EVENTS } from '../event-bus/event-bus.js';
import ListenerTracker from '../listener-tracker/listener-tracker-mixin.js';
import { getInstance, registerInstance } from '../instances-registry.js';

class PanelManager {
  constructor() {
    // Singleton check
    if (PanelManager.instance) {
      this.log.error('⚠️ PanelManager is singleton, returning existing instance');
      return PanelManager.instance;
    }

    this.debugMode = false;

    // 🎯 APLICĂ MIXIN-UL LISTENER TRACKER - ca Class_Terminate în VBA
    ListenerTracker.applyTo(this, {
      debugMode: this.debugMode || false,
      logPrefix: 'PanelManager',
      trackPerformance: true,
    });

    // 🎛️ CONFIGURAȚIE PANELE
    this.panels = {
      'panel-stanga': {
        id: 'panel-stanga',
        type: 'left',
        isVisible: false,
        isSticky: false, // pentru sticky panel
        containerClass: 'with-left-panel',
        buttonSelector: '[data-panel="panel-stanga"]', // pentru click handlers
      },
      'panel-dreapta': {
        id: 'panel-dreapta',
        type: 'right',
        isVisible: false,
        isSticky: false, // pentru sticky panel
        containerClass: 'with-right-panel',
        buttonSelector: '[data-panel="panel-dreapta"]',
      },
      'panel-jos': {
        id: 'panel-jos',
        type: 'bottom',
        isVisible: false,
        isSticky: false, // pentru sticky panel
        containerClass: 'with-bottom-panel',
        buttonSelector: '[data-panel="panel-jos"]',
      },
    };

    // Store singleton instance
    PanelManager.instance = this;

    // 🎯 AUTO-REGISTER în registry
    registerInstance('panelManager', this, {
      version: '3.1.0',
      description: 'Main panel manager for dashboard with event-bus integration',
      dependencies: ['eventBus', 'filterManager', 'listenerTracker'],
    });

    this.mainContainer = null;

    // 📊 STATS PENTRU TRACKING
    this.stats = {
      panelToggles: 0,
      panelShows: 0,
      panelHides: 0,
      quickActions: 0,
      errors: 0,
    };
  }

  /**
   * Inițializare - echivalent cu Form_Load în VBA
   */
  init() {
    this.mainContainer = document.querySelector('.main-container');

    // Verifică dacă main container există
    if (!this.mainContainer) {
      this.log.error('❌ Main container nu a fost găsit');
      return false;
    }

    // 📡 Setup event listeners (tracking automat)
    this.setupEventListeners();

    // Inițializează starea panelelor
    this.initializePanels();

    // 📡 Emit eveniment că panel manager e gata
    // eventBus.emit(EVENTS.PANEL_MANAGER_READY, {
    //   panelCount: Object.keys(this.panels).length,
    //   timestamp: Date.now(),
    // });

    this.log('✅ Panel Manager inițializat cu succes');
    return true;
  }

  /**
   * 📡 SETUP EVENT LISTENERS - cu tracking automat
   * Echivalent cu WithEvents în VBA
   */
  setupEventListeners() {
    // 🎧 EVENT BUS LISTENERS - tracking automat prin ListenerTracker
    // this.addBusListener(EVENTS.PANEL_TOGGLE_REQUEST, (eventData) => {
    //   const { panelId } = eventData.data;
    //   this.togglePanel(panelId);
    // });

    this.addBusListener(EVENTS.PANEL_SHOW_REQUEST, (eventData) => {
      //const { panelId } = eventData.data;
      this.showPanel(eventData);
    });

    this.addBusListener(EVENTS.PANEL_HIDE_REQUEST, (eventData) => {
      const { panelId } = eventData.data;
      this.hidePanel(panelId);
    });

    this.addBusListener(EVENTS.PANEL_POPULATED, (eventData) => {
      const { panelId } = eventData.data;
      this.finalizePanel(panelId);
    });

    this.addBusListener(EVENTS.PANEL_CLOSE_ALL_REQUEST, () => {
      this.closeAllPanels();
    });

    this.addBusListener(EVENTS.PANEL_STICKY_TOGGLE_REQUEST, (eventData) => {
      const { panelId } = eventData.data;
      this.toggleStickyPanel(panelId);
    });

    this.log('📡 Event listeners configurate cu tracking automat');
  }

  /**
   * Inițializează panelele - toate ascunse la început
   */
  initializePanels() {
    Object.values(this.panels).forEach((panel) => {
      const element = document.getElementById(panel.id);
      if (element) {
        // Asigură-te că panelul e ascuns inițial
        element.classList.add('hidden');
        element.classList.remove('visible');
        panel.isVisible = false;
      }
    });

    // Resetează main container
    this.resetMainContainer();
  }

  /**
   * Toggle panel - principala funcție ca în VBA
   * @param {string} panelId - ID-ul panelului
   */
  togglePanel(panelId) {
    const panel = this.panels[panelId];

    if (!panel) {
      this.log.error(`❌ Panel ${panelId} nu există`);
      this.stats.errors++;
      return;
    }

    const element = document.getElementById(panelId);
    if (!element) {
      this.log.error(`❌ Element DOM pentru ${panelId} nu a fost găsit`);
      this.stats.errors++;
      return;
    }

    // Toggle logic - ca în VBA: If Control.Visible Then Control.Visible = False
    if (panel.isVisible) {
      this.hidePanel(panelId);
    } else {
      this.showPanel(panelId);
    }

    this.stats.panelToggles++;

    // 📡 Emit eveniment pentru alte module
    eventBus.emit(EVENTS.PANEL_TOGGLED, {
      panelId,
      isVisible: panel.isVisible,
      type: panel.type,
    });
  }

  showPanel(eventData) {
    const { panelId, requestSource } = eventData.data;
    const panel = this.panels[panelId];
    const element = document.getElementById(panelId);

    if (!panel || !element) {
      this.stats.errors++;
      return;
    }

    // Afișează panelul cu animație
    element.classList.remove('hidden');
    this.mainContainer.classList.add(panel.containerClass);
    panel.isVisible = true;
    this.stats.panelShows++;

    // Forțează reflow și animație
    element.offsetHeight;
    this.addTimeout(() => {
      element.classList.add('visible');
    }, 10);

    // Il asculta filter-panel-manager
    this.addTimeout(() => {
      eventBus.emit(EVENTS.PANEL_SHOWN, {
        panelId,
        type: panel.type,
        requestSource,
        timestamp: Date.now(),
      });

      // 📡 IMEDIAT emit TABLE_RESIZE cu overhead-ul panelului
      eventBus.emit(EVENTS.TABLE_RESIZE, {
        source: `panel-show-${panelId}`,
        timestamp: Date.now(),
      });
    }, 400);

    this.log(`✅ Panel ${panelId} în curs de afișare`);
  }

  hidePanel(panelId) {
    const panel = this.panels[panelId];
    const element = document.getElementById(panelId);

    if (!panel || !element) {
      this.stats.errors++;
      return;
    }

    // Start animație
    element.classList.remove('visible');
    this.mainContainer.classList.remove(panel.containerClass);
    panel.isVisible = false;
    this.stats.panelHides++;

    // După animație, finalizează
    this.addTimeout(() => {
      element.classList.add('hidden');

      eventBus.emit(EVENTS.PANEL_HIDDEN, {
        panelId,
        type: panel.type,
        timestamp: Date.now(),
      });

      eventBus.emit(EVENTS.TABLE_RESIZE, {
        source: `panel-hide-${panelId}`,
        timestamp: Date.now(),
      });
    }, 300);

    this.log(`✅ Panel ${panelId} în curs de ascundere`);
  }

  /**
   * Închide panelele laterale opuse
   * @param {string} currentPanelId
   */
  closeOtherSidePanels(currentPanelId) {
    Object.values(this.panels).forEach((panel) => {
      if (
        panel.id !== currentPanelId &&
        (panel.type === 'left' || panel.type === 'right') &&
        panel.isVisible
      ) {
        this.hidePanel(panel.id);
      }
    });
  }

  /**
   * Închide toate panelele
   */
  closeAllPanels() {
    const visiblePanels = this.getVisiblePanels();

    Object.keys(this.panels).forEach((panelId) => {
      if (this.panels[panelId].isVisible) {
        this.hidePanel(panelId);
      }
    });

    // 📡 Emit eveniment pentru alte module
    eventBus.emit(EVENTS.PANELS_ALL_CLOSED, {
      closedPanels: visiblePanels,
      timestamp: Date.now(),
    });
  }

  finalizePanel(Data) {
    const panel = this.panels[Data];
    panel.isVisible = true; // Asigură-te că panelul este marcat ca vizibil
    this.log(`✅ Panel ${Data} populat și afișat`);
  }
  /**
   * Resetează main container la starea inițială
   */
  resetMainContainer() {
    Object.values(this.panels).forEach((panel) => {
      this.mainContainer.classList.remove(panel.containerClass);
    });
  }

  /**
   * Actualizează detaliile selecției în panelul jos
   * @param {Object} selectedRowData
   */
  updateSelectionDetails(selectedRowData) {
    const detailsContainer = document.getElementById('selection-details');

    if (!detailsContainer) return;

    if (!selectedRowData) {
      detailsContainer.innerHTML = '<p>Selectează un rând din tabel pentru a vedea detaliile</p>';
      return;
    }

    // Construiește HTML-ul cu detaliile
    let detailsHTML = '<div class="selection-info">';

    Object.entries(selectedRowData).forEach(([key, value]) => {
      if (key !== 'record-selector' && value !== null && value !== undefined) {
        detailsHTML += `
                    <div class="detail-row">
                        <span class="detail-label">${key}:</span>
                        <span class="detail-value">${value}</span>
                    </div>
                `;
      }
    });

    detailsHTML += '</div>';
    detailsContainer.innerHTML = detailsHTML;

    // 📡 Emit eveniment pentru alte module
    eventBus.emit(EVENTS.SELECTION_DETAILS_UPDATED, {
      selectedRowData,
      hasData: !!selectedRowData,
    });
  }

  /**
   * Adaugă o intrare în istoricul modificărilor
   * @param {string} action
   */
  addToHistory(action) {
    const historyContainer = document.getElementById('change-history');

    if (!historyContainer) return;

    const now = new Date();
    const timeString = now.toLocaleTimeString('ro-RO', {
      hour: '2-digit',
      minute: '2-digit',
    });

    // Creează noul element de istoric
    const historyItem = document.createElement('div');
    historyItem.className = 'history-item';
    historyItem.innerHTML = `
            <span class="history-time">${timeString}</span>
            <span class="history-action">${action}</span>
        `;

    // Adaugă la începutul listei
    historyContainer.insertBefore(historyItem, historyContainer.firstChild);

    // Păstrează doar ultimele 10 intrări
    const items = historyContainer.querySelectorAll('.history-item');
    if (items.length > 10) {
      items[items.length - 1].remove();
    }

    // 📡 Emit eveniment pentru alte module
    eventBus.emit(EVENTS.HISTORY_ADDED, {
      action,
      timestamp: timeString,
      totalItems: items.length,
    });
  }

  /**
   * Verifică dacă un panel este vizibil
   * @param {string} panelId
   * @returns {boolean}
   */
  isPanelVisible(panelId) {
    if (!this.panels[panelId]) {
      return false;
    }
    return this.panels[panelId]?.isVisible || false;
  }

  /**
   * Obține lista panelelor vizibile
   * @returns {Array<string>}
   */
  getVisiblePanels() {
    return Object.keys(this.panels).filter((panelId) => this.panels[panelId].isVisible);
  }

  /**
   * 🔄 REFRESH COMPLET - reîncarcare panele
   */
  refresh() {
    this.log('🔄 Refresh panel manager...');

    // Închide toate panelele
    this.closeAllPanels();

    // Reinițializează
    this.initializePanels();

    // 📡 Emit eveniment
    eventBus.emit(EVENTS.PANEL_MANAGER_REFRESHED, {
      timestamp: Date.now(),
      stats: this.getStats(),
    });

    this.log('✅ Panel manager refreshed');
  }

  getPanelDimensions(panelId) {
    const element = document.getElementById(panelId);
    if (!element) return { width: 0, height: 0 };

    // Citește din CSS custom properties sau getComputedStyle
    const computedStyle = getComputedStyle(document.documentElement);
    const panelWidth = parseInt(computedStyle.getPropertyValue('--panel-width')) || 0;
    const panelBottomHeight =
      parseInt(computedStyle.getPropertyValue('--panel-bottom-height')) || 0;

    return {
      panelWidth: panelWidth,
      panelHeight: panelBottomHeight,
    };
  }

  /**
   * 🗑️ CLEANUP COMPLET - pentru când componenta se distruge
   * Echivalent cu Class_Terminate în VBA
   */
  destroy() {
    this.log('🗑️ Destrucție PanelManager...');

    // Închide toate panelele
    this.closeAllPanels();

    // Resetează main container
    this.resetMainContainer();

    // 📡 Cleanup automat prin ListenerTracker
    const cleanupStats = this.cleanupAllListeners();

    // Clear singleton instance
    PanelManager.instance = null;

    // 📡 Emit eveniment final
    // eventBus.emit(EVENTS.PANEL_MANAGER_DESTROYED, {
    //   cleanupStats,
    //   finalStats: this.getStats(),
    // });

    this.log('✅ Panel Manager eliminat complet', cleanupStats);
  }

  /**
   * Log pentru debugging
   */
  log = (() => {
    const fn = (message, data = null) => {
      if (this.debugMode) {
        const now = new Date();
        const ts = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now
          .getMilliseconds()
          .toString()
          .padStart(3, '0')}`;
        const CPN = 'PanelManager'.padEnd(15);
        console.log(
          `%c[${ts}] [${CPN}] ${message}`,
          'color: #76319dff; font-weight: bold;',
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
      const CPN = 'PanelManager'.padEnd(15);
      console.error(
        `%c[${ts}] [${CPN}] ${message}`,
        'color: #ff3333; font-weight: bold;',
        data ?? ''
      );
    };

    return fn;
  })(this);
}

// 🎯 CREEAZĂ INSTANȚA GLOBALĂ SINGLETON
const panelManager = new PanelManager();

// 🌍 EXPORT PENTRU MODULE
export default panelManager;
