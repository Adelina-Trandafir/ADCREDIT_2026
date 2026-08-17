// .static/js/dashboard/tabs.js

//import '../global-variables.js';
import eventBus, { EVENTS } from '../event-bus/event-bus.js';
import ListenerTracker from '../listener-tracker/listener-tracker-mixin.js';
import { registerInstance } from '../instances-registry.js';

class Tabs {
  constructor() {
    // Singleton check
    if (Tabs.instance) {
      console.warn('⚠️ Tabs is singleton, returning existing instance');
      return Tabs.instance;
    }

    this.debugMode = false;

    // 🎯 APLICĂ MIXIN-UL LISTENER TRACKER
    ListenerTracker.applyTo(this, {
      debugMode: this.debugMode || false,
      logPrefix: 'Tabs',
      trackPerformance: true,
    });

    this.isInitialized = false;
    this.isLoading = false;
    this.currentTab = 'nvB1'; // Tab-ul activ inițial
    this.currentView = 'viewBaza_PYTHON'; // View-ul curent inițial
    this.viewToSelTab = {
      viewBaza_PYTHON: 'nvB1',
      viewDosar_2025: 'nvB2',
      viewIpotecare_2025: 'nvB3',
    };
    this.selTabToView = {
      nvB1: 'viewBaza_PYTHON',
      nvB2: 'viewDosar_PYTHON',
      nvB3: 'viewIpotecare_PYTHON',
    };
    // Store singleton instance
    Tabs.instance = this;

    // 🎯 AUTO-REGISTER în registry
    registerInstance('Tabs', this, {
      version: '3.0.0',
      description: 'Main tabs controller for dashboard',
      features: ['tab-switching', 'event-driven'],
      dependencies: ['eventBus', 'ListenerTracker'],
    });
  }

  init() {
    this.setupEventListeners();
    this.log('🚀 TABS Initializat');
    return true;
  }

  setupEventListeners() {
    // Evenimente de la table-controller
    // eventBus.on(EVENTS.DATA_LOAD_SUCCESS, () => this.initTabs(), this);
    // this.addBusListener(EVENTS.TABLE_RESIZE, () => this.initTabs());
    this.addBusListener(EVENTS.TAB_CLICKED_OTHER, (data) => this.handleTabClick(false, data));
    this.addBusListener(EVENTS.TAB_CLICKED_SAME, (data) => this.handleTabClick(true, data));
  }

  handleTabClick(sameTab, data) {
    this.currentTab = data.data.trim();
    this.currentView = this.viewToSelTab[this.currentTab];

    if (!this.currentView) {
      this.log.error(`⚠️ Tab necunoscut: ${this.currentTab}`);
      return;
    }
  }

  initTabs() {
    document.querySelectorAll('.nav-tab').forEach((tab) => {
      tab.replaceWith(tab.cloneNode(true)); // remove all listeners
      this.log(`Listener eliminat ${tab.innerHTML}`);
    });

    document.querySelectorAll('.nav-tab').forEach((tab) => {
      tab.addEventListener('click', () => {
        const view = tab.dataset.view;

        if (this.currentTab === view) eventBus.emit('same-tab-clicked', view);
        else eventBus.emit('other-tab-clicked', view);

        this.currentTab = view;
      });
    });

    // this.currentTab = currentView;
  }

  destroy() {
    this.isInitialized = false;
    this.isLoading = false;
    this.currentTab = '';

    // Elimină event listeners DOM
    const cleanupStats = this.cleanupAllListeners();

    // Eliberează singleton-ul
    Tabs.instance = null;

    this.log(`✅ Tabs distrus ${cleanupStats}`);
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
        const CPN = 'TABS'.padEnd(15);
        console.log(
          `%c[${ts}] [${CPN}] ${message}`,
          'color: #7371ffff; font-weight: bold;',
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
      const CPN = 'TABS'.padEnd(15);
      console.error(
        `%c[${ts}] [${CPN}] ${message}`,
        'color: #ff3333; font-weight: bold;',
        data ?? ''
      );
    };

    return fn;
  })(this);
}

const tabs = new Tabs();

// Export pentru module
export default tabs;
