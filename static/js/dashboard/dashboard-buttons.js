import eventBus, { EVENTS } from '../event-bus/event-bus.js';
import ListenerTracker from '../listener-tracker/listener-tracker-mixin.js';
import { getInstance, registerInstance } from '../instances-registry.js';

class DashboardButtons {
  constructor() {
    // Singleton check
    if (DashboardButtons.instance) {
      this.log.error('⚠️ DashboardButtons is singleton, returning existing instance');
      return DashboardButtons.instance;
    }

    this.debugMode = false;

    // Aplică mixin-ul listener tracker
    ListenerTracker.applyTo(this, {
      debugMode: this.debugMode || false,
      logPrefix: 'DashboardButtons',
      trackPerformance: true,
    });

    this.header_button1 = null;
    this.footer_button1 = null;
    this.footer_button2 = null;
    this.footer_button3 = null;
    this.footer_button4 = null;
    this.footer_button5 = null;

    // 🆕 PROTECȚIE CLICK-URI MULTIPLE
    this.isProcessingClick = false;
    this.lastClickTime = 0;
    this.clickDebounceTime = 300; // 300ms între click-uri
    this.areEventsSetUp = false;

    // Store singleton instance
    DashboardButtons.instance = this;

    // 🎯 AUTO-REGISTER în registry
    registerInstance('dashboardButtons', this, {
      version: '3.0.0',
      description: 'Main dashboard buttons manager',
      features: ['stats', 'event-driven', 'click-handling', 'filtering'],
      dependencies: ['eventBus'],
    });
  }

  init() {
    this.log('🚀 Initializing DashboardButtons...');
    this.header_button1 = document.getElementById('logoutBtn');
    this.footer_button1 = document.getElementById('footer-button1');
    this.footer_button2 = document.getElementById('footer-button2');
    this.footer_button3 = document.getElementById('footer-button3');
    this.footer_button4 = document.getElementById('footer-button4');
    this.footer_button5 = document.getElementById('footer-button5');

    if (
      !this.header_button1 ||
      !this.footer_button1 ||
      !this.footer_button2 ||
      !this.footer_button3 ||
      !this.footer_button4 ||
      !this.footer_button5
    ) {
      this.log.error('❌ One or more buttons not found in the DOM.');
      return;
    }

    this.setupEventListeners();
    return true;
  }

  setupEventListeners() {
    if (this.areEventsSetUp) {
      this.log('⚠️ Event listeners already set up, skipping...');
      return;
    }

    this.log('🛠️ Setting up event listeners for buttons...');
    this.addClickListener(this.footer_button1, this.handleFooterButton1Click.bind(this));
    this.addClickListener(this.footer_button2, this.handleFooterButton2Click.bind(this));
    this.addClickListener(this.footer_button3, this.handleFooterButton3Click.bind(this));
    this.addClickListener(this.footer_button4, this.handleFooterButton4Click.bind(this));
    this.addClickListener(this.footer_button5, this.handleFooterButton5Click.bind(this));

    this.areEventsSetUp = true;
  }

  handleFooterButton1Click(event) {
    if (event.currentTarget === this.footer_button1) {
      event.stopPropagation();
      event.preventDefault();

      const currentTab = getInstance('tabs').currentTab || 'unknown';

      if (currentTab.toLowerCase() === 'nvb1') {
        eventBus.emit(EVENTS.ROW_OPTIONS_CLICKED, { rowAction: 'addLead' });
      }
      this.log('🔘 Footer Button 1 clicked');
    }
  }
  handleFooterButton2Click(event) {
    if (event.currentTarget === this.footer_button2) {
      event.stopPropagation();
      event.preventDefault();

      const currentTab = sessionData.getCurrentTab();
      this.log('🔘 Footer Button 2 clicked');
    }
  }

  handleFooterButton3Click(event) {
    this.log('🔘 Footer Button 3 clicked');
  }

  handleFooterButton4Click(event) {
    this.log('🔘 Footer Button 4 clicked');
  }

  handleFooterButton5Click(event) {
    this.log('🔘 Footer Button 5 clicked - Transferă Lead');
    if (event.currentTarget === this.footer_button5) {
      event.stopPropagation();
      event.preventDefault();

      // Gaseste randul selectat curent (clasa 'clicked' = single select)
      const selectedRow = document.querySelector('#tableBody tr.clicked');
      if (!selectedRow) {
        this.log('⚠️ Niciun rând selectat pentru Transfer Lead');
        return;
      }

      const rowId = selectedRow.dataset.rowId;
      const tableBuilder = getInstance('tableBuilder');
      const rowData = tableBuilder?.rows?.get(parseInt(rowId))?.originalData || null;

      eventBus.emit(EVENTS.TRANSFER_LEAD_OPEN_REQUEST, { rowId, rowData });
    }
  }

  destroy() {
    this.log('🧹 Destroying DashboardButtons instance and cleaning up...');
    this.removeAllListeners();
    DashboardButtons.instance = null;
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
        const CPN = 'DashboardButtons'.padEnd(15);
        console.log(
          `%c[${ts}] [${CPN}] ${message}`,
          'color: #00468bff; font-weight: bold;',
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
      const CPN = 'DashboardButtons'.padEnd(15);
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
const dashboardButtons = new DashboardButtons();

// Export pentru module
export default dashboardButtons;
