/**
 * TRANSFER LEAD MANAGER
 * Orchestrator principal. Singleton.
 * Coordoneaza toate modulele si asculta evenimente din EventBus.
 *
 * @version 1.0.0
 */

import eventBus, { EVENTS } from '../../event-bus/event-bus.js';
import ListenerTracker from '../../listener-tracker/listener-tracker-mixin.js';
import { registerInstance } from '../../instances-registry.js';

import * as LoaderManager from './transfer-lead-loader.js';
import * as DomBuilder from './transfer-lead-dom.js';
import * as FormManager from './transfer-lead-form.js';
import * as StateManager from './transfer-lead-state.js';
import * as DataManager from './transfer-lead-data.js';
import * as TabManager from './transfer-lead-tabs.js';
import { initAnafSearch } from './transfer-lead-anaf.js';

import { FINANCIAR_TAB_CONFIG } from './transfer-lead-tab-financiar.js';
import { BANCAR_TAB_CONFIG } from './transfer-lead-tab-bancar.js';
import { DOSAR_TAB_CONFIG } from './transfer-lead-tab-dosar.js';
import { OBSERVATII_TAB_CONFIG } from './transfer-lead-tab-observatii.js';
import { EXTRA_TAB_CONFIG } from './transfer-lead-tab-extra.js';

class TransferLeadManager {
  constructor() {
    // Singleton pattern
    if (TransferLeadManager.instance) {
      return TransferLeadManager.instance;
    }
    TransferLeadManager.instance = this;

    // ===== STARE =====
    this.debugMode = false;
    this.isInitialized = false;
    this.isVisible = false;
    this.panelElement = null;
    this.currentRowId = null;
    this.currentRowData = null;
    this.originalData = null;
    this.isDirty = false;
    this.activeTabId = null;

    // Registrii
    this.tabRegistry = new Map();
    this.builtTabs = new Set();

    // Flags de initializare tab-uri
    this.financiarComponentsInit = false;
    this.bancarComponentsInit = false;

    // Date formular
    this.formData = {};
    this.pendingComboData = new Map();

    // Componente
    this.components = {
      clientInputs: new Map(),
      dosarInputs: new Map(),
      functiaComponents: new Map(),
      financiar: new Map(),
      bancar: new Map(),
    };

    // Statistici
    this.stats = {
      opens: 0,
      saves: 0,
      cancels: 0,
    };

    // Aplica ListenerTracker mixin
    ListenerTracker.applyTo(this, {
      debugMode: this.debugMode,
      logPrefix: 'TransferLead',
      trackPerformance: false,
    });

    // Inregistreaza in registry
    registerInstance('transferLeadManager', this, {
      version: '1.0.0',
      description: 'Transfer Lead panel manager',
      dependencies: ['eventBus', 'listenerTracker', 'combobox'],
    });
  }

  // ============================================================
  // LOGGING
  // ============================================================
  log = (() => {
    const fn = (message, data = null) => {
      if (this.debugMode) {
        const now = new Date();
        const ts = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now
          .getMilliseconds()
          .toString()
          .padStart(3, '0')}`;
        const CPN = 'TransferLead'.padEnd(15);
        console.log(
          `%c[${ts}] [${CPN}] ${message}`,
          'color: #e67e22; font-weight: bold;',
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
      const CPN = 'TransferLead'.padEnd(15);
      console.error(
        `%c[${ts}] [${CPN}] ${message}`,
        'color: #e74c3c; font-weight: bold;',
        data ?? ''
      );
    };

    return fn;
  })();

  // ============================================================
  // INITIALIZARE
  // ============================================================

  async init() {
    if (this.isInitialized) return;

    this.log('Initializare TransferLeadManager...');

    try {
      // 1. Incarca stylesheet-ul
      await LoaderManager.loadTransferLeadStyles(this);

      // 2. Construieste DOM-ul panelului
      this.panelElement = DomBuilder.buildPanelElement(this);

      // 3. Inregistreaza tab-urile
      TabManager.registerTab(this, FINANCIAR_TAB_CONFIG);
      TabManager.registerTab(this, BANCAR_TAB_CONFIG);
      TabManager.registerTab(this, DOSAR_TAB_CONFIG);
      TabManager.registerTab(this, OBSERVATII_TAB_CONFIG);
      TabManager.registerTab(this, EXTRA_TAB_CONFIG);

      // 4. Construieste bara de tab-uri
      TabManager.initTabs(this);

      // 5. Seteaza componentele formularului
      FormManager.setupFormComponents(this);

      // 6. Seteaza listenerii pentru date extra
      DataManager.setupDataListeners(this);

      // 7. Initializeaza cautarea ANAF
      initAnafSearch(this);

      // 8. Seteaza listenerii proprii
      this._setupEventListeners();

      // 9. Incarca datele statice initiale
      DataManager.loadInitialData(this);

      this.isInitialized = true;
      this.log('TransferLeadManager initializat cu succes');
    } catch (err) {
      this.log.error('Eroare la initializare', err);
    }
  }

  // ============================================================
  // EVENT LISTENERS
  // ============================================================

  _setupEventListeners() {
    // Cereri de deschidere panel
    this.addBusListener(EVENTS.TRANSFER_LEAD_OPEN_REQUEST, (data) => {
      const payload = data?.data || data;
      this.openPanel(payload?.rowId, payload?.rowData);
    });

    // ANAF select - actualizeaza combobox-ul Companie
    this.addBusListener(EVENTS.ANAF_SEARCH_SELECT, (data) => {
      const { cui, denumire } = data?.data || data;
      const combo = this.components.functiaComponents.get('tl-companie-container');
      if (combo) combo.setValue(cui, denumire);
      this.formData.CUI = cui;
      this.formData.Companie = denumire;
      FormManager.markDirty(this);
    });

    // Butoane panel
    const saveBtn = this.panelElement.querySelector('#tl-btn-save');
    if (saveBtn) {
      this.addDOMListener(saveBtn, 'click', () => StateManager.saveChanges(this));
    }

    const renuntaBtn = this.panelElement.querySelector('#tl-btn-renunta');
    if (renuntaBtn) {
      this.addDOMListener(renuntaBtn, 'click', () => StateManager.cancelChanges(this));
    }
  }

  // ============================================================
  // METODE PUBLICE DELEGATE
  // ============================================================

  async openPanel(rowId, rowData) {
    return StateManager.openPanel(this, rowId, rowData);
  }

  async closePanel() {
    return StateManager.closePanel(this);
  }

  async saveChanges() {
    return StateManager.saveChanges(this);
  }

  async cancelChanges() {
    return StateManager.cancelChanges(this);
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  destroy() {
    this.clearAllListeners();
    try {
      const overlayManager = window.__overlayManagerInstance;
      if (overlayManager) overlayManager.unsubscribe(this);
    } catch {
      // ignore
    }

    if (this.panelElement) {
      this.panelElement.remove();
      this.panelElement = null;
    }

    TransferLeadManager.instance = null;
    this.log('TransferLeadManager distrus');
  }
}

// Creaza singleton si initializeaza automat la import
const transferLeadManager = new TransferLeadManager();

// Auto-init la DOMContentLoaded sau imediat daca DOM-ul e gata
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => transferLeadManager.init());
} else {
  // Delay mic pentru a permite celorlalte module sa se inregistreze
  setTimeout(() => transferLeadManager.init(), 0);
}

export default transferLeadManager;
