/**
 * 🚀 DASHBOARD.JS - VERSIUNEA NOUĂ EVENT-DRIVEN - REFACTORIZAT ÎN CLASĂ
 * Compatibil cu arhitectura refactorizată + ES6 Registry
 *
 * DIFERENȚE MAJORE FAȚĂ DE VERSIUNEA VECHE:
 * ✅ Folosește table-controller.js în loc de table.js direct
 * ✅ Folosește filter-manager.js în loc de filter-core.js direct
 * ✅ Comunicare prin event-bus în loc de apeluri directe
 * ✅ Mult mai simplu și curat - toată logica complexă e în controllere
 * ✅ Păstrează EXACT aceeași funcționalitate pentru utilizator
 * ✅ ACUM CLASĂ - consistent cu restul arhitecturii
 * ✅ REGISTRY ES6 - zero window globals pentru instanțe
 *
 * @version 3.1.1 - Event-Driven Architecture + Class Structure + ES6 Registry
 * @author Adelina Trandafir - Avatar Soft SRL
 */

// ========== IMPORT-URI NOI - ARHITECTURA REFACTORIZATĂ + REGISTRY ==========
import eventBus, { EVENTS } from './event-bus/event-bus.js';

import {
  getInstance,
  registerInstance,
  unregisterInstance,
  clearAllInstances,
  getAvailableInstances,
  getRegistryStats,
} from './instances-registry.js';

// Import pentru auto-create SessionData
import './session/session-data.js';
import sessionData from './session/session-data.js';

import './session/session-monitoring.js';

import './utils/overlay-manager.js';

import './dashboard/data-loader.js';
import './dashboard/data-loader-extra.js';
import './dashboard/table-controller/table-controller-manager.js';
import './dashboard/table-builder/table-builder-manager.js';
import './dashboard/details-panel-baza/details-panel-baza.js';
import './dashboard/dashboard-buttons.js';
import './dashboard/tabs.js';
import './dashboard/stats.js';
import './dashboard/panel-manager.js';
import './dashboard/options-manager.js';
import './dashboard/filter/filter-manager.js';
import './dashboard/filter/filter-panel.js';
import './dashboard/feedback-modal/feedback-manager.js';
import './dashboard/add-lead-modal/add-lead-manager.js';
import './dashboard/transfer-lead/transfer-lead-manager.js';

class Dashboard {
  constructor() {
    this.debugMode = false;
    this.isInitialized = false;
    this.sortFilterLoaded = false;

    this.overlay = null;

    // 🎯 REFERENCES LA INSTANȚE VIA REGISTRY (nu window globals)
    this.dataLoader = null;
    this.dataLoaderExtra = null;
    this.tableController = null;
    this.tableBuilder = null;
    this.filterManager = null;
    this.tabs = null;
    this.stats = null;
    this.panels = null;
    this.options = null;
    //this.filterPanel = null;
    this.detailsPanel = null;
    this.drepturi = null;
    this.feedBackModal = null;
    this.addLeadModal = null;
    this.dashboardButtons = null;
  }

  /**
   * 🎯 INIȚIALIZAREA PRINCIPALĂ - SIMPLIFICATĂ PRIN CONTROLLERE + REGISTRY
   */
  async init() {
    if (this.isInitialized) {
      this.log('⚠️ Dashboard deja inițializat');
      return true;
    }

    await this.getSessionInfoFromServer();
    await this.getUserRights();

    try {
      // ========== ETAPA 1: GET INSTANȚE DIN REGISTRY CU FALLBACK ==========
      this.log('🎮 Obțin instanțele din registry cu fallback...');

      // DataLoader - încearcă registry, fallback la import direct
      try {
        this.overlay = getInstance('overlayManager');
        if (!this.overlay) {
          this.log.error('⚠️ OverlayManager nu e în registry!');
        } else {
          this.log('✅ OverlayManager obținut din registry');
        }

        this.dataLoader = getInstance('dataLoader');
        if (!this.dataLoader) {
          this.log.error('⚠️ DataLoader nu e în registry!');
        } else {
          this.log('✅ DataLoader obținut din registry');
        }

        this.dataLoaderExtra = getInstance('dataLoaderExtra');
        if (!this.dataLoaderExtra) {
          this.log.error('⚠️ dataLoaderExtra nu e în registry!');
        } else {
          this.log('✅ dataLoaderExtra obținut din registry');
        }

        this.tableBuilder = getInstance('tableBuilder');
        if (!this.tableBuilder) {
          this.log.error('⚠️ TableBuilder nu e în registry!');
        } else {
          this.log('✅ TableBuilder obținut din registry');
        }

        this.stats = getInstance('stats');
        if (!this.stats) {
          this.log.error('⚠️ Stats nu e în registry!');
        } else {
          this.log('✅ Stats obținut din registry');
        }

        this.tableController = getInstance('tableController');
        if (!this.tableController) {
          this.log.error('⚠️ TableController nu e în registry!');
        } else {
          this.log('✅ TableController obținut din registry');
        }

        this.filterManager = getInstance('filterManager');
        if (!this.filterManager) {
          this.log.error('⚠️ FilterManager nu e în registry!');
        } else {
          this.log('✅ FilterManager obținut din registry');
        }

        this.dashboardButtons = getInstance('dashboardButtons');
        if (!this.dashboardButtons) {
          this.log.error('⚠️ DashboardButtons nu e în registry!');
        } else {
          this.log('✅ DashboardButtons obținut din registry');
        }

        this.tabs = getInstance('tabs');
        if (!this.tabs) {
          this.log.error('⚠️ Tabs nu e în registry!');
        } else {
          this.log('✅ Tabs obținut din registry');
        }

        this.panels = getInstance('panelManager');
        if (!this.panels) {
          this.log.error('⚠️ PanelManager nu e în registry!');
        } else {
          this.log('✅ PanelManager obținut din registry');
        }

        this.options = getInstance('optionsManager');
        if (!this.options) {
          this.log.error('⚠️ OptionsManager nu e în registry!');
        } else {
          this.log('✅ OptionsManager obținut din registry');
        }

        this.sessionMonitoring = getInstance('sessionMonitoring');
        if (!this.sessionMonitoring) {
          this.log.error('⚠️ SessionMonitoring nu e în registry!');
        } else {
          this.log('✅ Monitoring obținut din registry');
        }

        this.filterPanel = getInstance('filterPanel');
        if (!this.filterPanel) {
          this.log.error('⚠️ FilterPanel nu e în registry!');
        } else {
          this.log('✅ FilterPanel obținut din registry');
        }

        this.detailsPanel = getInstance('detailsPanelBaza');
        if (!this.detailsPanel) {
          this.log.error('⚠️ DetailsPanelBaza nu e în registry!');
        } else {
          this.log('✅ DetailsPanelBaza obținut din registry');
        }

        this.feedBackModal = getInstance('feedbackModal');
        if (!this.feedBackModal) {
          this.log.error('⚠️ FeedbackModal nu e în registry!');
        } else {
          this.log('✅ FeedbackModal obținut din registry');
        }

        this.addLeadModal = getInstance('addLeadModal');
        if (!this.addLeadModal) {
          this.log.error('⚠️ AddLeadModal nu e în registry!');
        } else {
          this.log('✅ AddLeadModal obținut din registry');
        }
      } catch (error) {
        this.log.error('⚠️ Eroare la obținerea datelor din registru!', error);
      }

      this.log('🎮 Inițializez controllere noi...');

      try {
        this.log('✅ Începe inițializarea OverlayManager...');
        const overlayInitResult = this.overlay.init();
        if (!overlayInitResult) {
          throw new Error('Overlay Manager inițializare eșuată');
        }

        this.log('✅ Incepe initializarea DataLoader...');
        const dataLoaderInitResult = this.dataLoader.init();
        if (!dataLoaderInitResult) {
          throw new Error('Data Loader inițializare eșuată');
        }

        this.log('✅ Incepe initializarea ExtraDataLoader...');
        const dataLoaderExtra = this.dataLoaderExtra.init();
        if (!dataLoaderExtra) {
          throw new Error('Extra Data Loader inițializare eșuată');
        }

        this.log('✅ Incepe initializarea TableBuilder...');
        const tableBuilderInitResult = this.tableBuilder.init();
        if (!tableBuilderInitResult) {
          throw new Error('Table Builder inițializare eșuată');
        }

        this.log('✅ Incepe initializarea STATS-urilor...');
        const statsInitResult = this.stats.init();
        if (!statsInitResult) {
          throw new Error('STATS inițializare eșuată');
        }

        this.log('✅ Incepe initializarea TableController...');
        const tableInitResult = await this.tableController.init({
          view: 'viewBaza_PYTHON',
          autoLoad: true,
        });

        if (!tableInitResult) {
          throw new Error('Table Controller inițializare eșuată');
        }

        this.log('✅ Incepe initializarea FilterManager...');
        const filterInitResult = this.filterManager.init();

        if (!filterInitResult) {
          throw new Error('Filter Manager inițializare eșuată');
        }

        this.log('✅ Incepe initializarea Tab-urilor...');
        const tabsInitResult = this.tabs.init();

        if (!tabsInitResult) {
          throw new Error('TABS inițializare eșuată');
        }

        this.log('✅ Incepe initializarea butoanelor...');
        const dashboardButtonsInitResult = this.dashboardButtons.init();

        if (!dashboardButtonsInitResult) {
          throw new Error('DASHBOARD BUTTONS inițializare eșuată');
        }

        this.log('✅ Incepe initializarea PANEL-urilor...');
        const panelInitResult = this.panels.init();

        if (!panelInitResult) {
          throw new Error('PANEL inițializare eșuată');
        }

        this.log('✅ Incepe initializarea optiunilor...');
        const optionsInitResult = this.options.init();

        if (!optionsInitResult) {
          throw new Error('OPTIONS inițializare eșuată');
        }

        this.log('✅ Incepe initializarea monitorizarii...');
        const monitoringInitResult = this.sessionMonitoring.init();

        if (!monitoringInitResult) {
          throw new Error('Monitoring inițializare eșuată');
        }

        this.log('✅ Incepe initializarea filtrului din panel...');
        const filterPanelInitResult = this.filterPanel.init();

        if (!filterPanelInitResult) {
          throw new Error('FilterPanel inițializare eșuată');
        }

        this.log('✅ Incepe initializarea panoului cu detalii...');
        const detailsPanelInitResult = this.detailsPanel.init();

        if (!detailsPanelInitResult) {
          throw new Error('DetailsPanel inițializare eșuată');
        }

        this.log('✅ Incepe initializarea Feedback Modal...');
        const feedbackModalInitResult = this.feedBackModal.init();

        if (!feedbackModalInitResult) {
          throw new Error('Feedback Modal inițializare eșuată');
        }

        this.log('✅ Incepe initializarea AddLead Modal...');
        const addLeadModalInitResult = this.addLeadModal.init();

        if (!addLeadModalInitResult) {
          throw new Error('AddLead Modal inițializare eșuată');
        }
      } catch (error) {
        this.log.error('⚠️ Eroare la initierea elementelor din dashboard!', error);
      }

      // ========== ETAPA 5: ÎNREGISTRARE EVENT LISTENERS GLOBALI ==========
      this.setupGlobalEventListeners();

      this.isInitialized = true;
      this.log('🎉 Dashboard inițializat complet cu noua arhitectură + ES6 Registry!');

      // Il asculta stats/setupClickListeners
      eventBus.emit(EVENTS.DASHBOARD_READY, {
        timestamp: Date.now(),
      });

      return true;
    } catch (error) {
      console.error('❌ Eroare la inițializarea dashboard-ului:', error);
      // this.showErrorMessage(`Eroare la încărcarea dashboard-ului: ${error.message}`);
      return false;
    }
  }

  /**
   * 🎪 CONFIGUREAZĂ EVENT LISTENERS GLOBALI (PĂSTRAT EXACT)
   * Pentru a asculta evenimente importante din sistem
   */
  setupGlobalEventListeners() {
    // Ascultă erorile din sistem
    eventBus.on(EVENTS.ERROR_OCCURRED, (errorData) => {
      console.error('❌ Eroare din sistem:', errorData);
      //this.showErrorMessage(`Eroare: ${errorData.message}`);
    });

    // Ascultă când tabelul este construit
    eventBus.on(EVENTS.TABLE_BUILD_COMPLETE, (buildData) => {
      this.log(`✅ Tabel construit în ${buildData.buildTime}ms`);
    });
  }

  /**
   * 🔧 GET INSTANCE SAFE - Helper pentru a obține instanțe cu fallback
   */
  async getInstanceSafe(name, importPath) {
    try {
      const instance = getInstance(name);
      this.log(`✅ ${name} obținut din registry`);
      return instance;
    } catch (error) {
      this.log(`⚠️ ${name} nu e în registry, import dinamic din ${importPath}`);
      const module = await import(importPath);
      return module.default;
    }
  }

  /**
   * 📊 GET DASHBOARD STATUS - Helper pentru debugging
   */
  getStatus() {
    return {
      isInitialized: this.isInitialized,
      hasDataLoader: !!this.dataLoader,
      hasTableBuilder: !!this.tableBuilder,
      hasTableController: !!this.tableController,
      hasFilterManager: !!this.filterManager,
      hasTabs: !!this.tabs,
      hasStats: !!this.stats,
      currentView: this.tabs?.currentView || '',
    };
  }

  // 🔍 1. OBȚINE INFORMAȚII DESPRE SESIUNE
  async getSessionInfoFromServer() {
    try {
      let response = null;
      let data = null;
      let sessionInfo = null;

      response = await fetch('/api/connected-session-info', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
      });

      data = await response.json();

      if (data.success) {
        // Poți accesa toate datele:
        const IdConsultant = data.session_info.IdConsultant;
        const department = data.session_info.department;
        const IdNivel = data.session_info.IdNivel;
        const IdParinte = data.session_info.IdParinte;

        sessionData.set('Department', department);
        sessionData.set('IdConsultant', IdConsultant);
        sessionData.set('IdNivel', IdNivel);
        sessionData.set('IdParinte', IdParinte);

        sessionInfo = data.session_info;

        return sessionInfo;
      } else {
        this.log.error('❌ Eroare la obținerea informațiilor sesiune:', data.message);
        return null;
      }
    } catch (error) {
      this.log.error('❌ Eroare fetch:', error);
      return null;
    }
  }

  async getUserRights() {
    const response = await fetch('/api/drepturi-utilizator', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    const data = await response.json();

    if (data.success) {
      sessionData.set('Drepturi', data.rights);
      this.drepturi = data.rights;
    } else {
      this.log.error('❌ Eroare la obținerea drepturilor sesiune:', data.message);
      return null;
    }
  }

  /**
   * 🧹 CLEANUP - Pentru testing și memory management
   */
  destroy() {
    this.log('🧹 Destroying dashboard...');

    // Cleanup instances
    if (this.tableBuilder) {
      this.tableBuilder.destroy();
    }

    // Clear references
    this.dataLoader = null;
    this.tableBuilder = null;
    this.tableController = null;
    this.filterManager = null;
    this.tabs = null;
    this.stats = null;

    // Reset state
    this.isInitialized = false;
    this.sortFilterLoaded = false;

    this.log('✅ Dashboard destroyed');
  }

  /**
   * 📝 LOG pentru debugging (PĂSTRAT EXACT)
   */
  log = (() => {
    const fn = (message, data = null) => {
      if (this.debugMode) {
        const now = new Date();
        const ts = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now
          .getMilliseconds()
          .toString()
          .padStart(3, '0')}`;
        const CPN = 'DASHBOARD'.padEnd(15);
        console.log(
          `%c[${ts}] [${CPN}] ${message}`,
          'color: #77ff87ff; font-weight: bold;',
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
      const CPN = 'DASHBOARD'.padEnd(15);
      console.error(
        `%c[${ts}] [${CPN}] ${message}`,
        'color: #ef4444; font-weight: bold;',
        data ?? ''
      );
    };

    return fn;
  })();
}

// ========== CREEAZĂ INSTANȚA SINGLETON ==========
const dashboard = new Dashboard();

// ========== AUTO-REGISTER ÎN REGISTRY ==========
registerInstance('dashboard', dashboard, {
  version: '3.1.1',
  description: 'Main dashboard controller with ES6 registry support',
  features: ['event-driven', 'registry-based', 'singleton'],
  dependencies: [
    'dataLoader',
    'tableBuilder',
    'stats',
    'tableController',
    'filterManager',
    'tabs',
    'sessionMonitoring',
  ],
});

// ========== INIȚIALIZARE SIGURĂ - O SINGURĂ DATĂ (PĂSTRAT EXACT) ==========
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => dashboard.init());
} else {
  // DOM deja încărcat
  dashboard.init();
}

// ========== EXPORT PENTRU MODULE ==========
export default dashboard;
