// js/components/dashboard/add-lead-modal/add-lead-manager.js
/**
 * 📞 ADD LEAD MODAL MANAGER
 * Gestionează modal-ul de adăugare lead-uri cu verificare telefon
 * ✨ UPDATE: Integrare phone formatter pentru input mask automat
 *
 * @version 2.0.0
 * @author Adelina Trandafir - Avatar Soft SRL
 */

import eventBus, { EVENTS } from '../../event-bus/event-bus.js';
import sessionData from '../../session/session-data.js';
import ListenerTracker from '../../listener-tracker/listener-tracker-mixin.js';
import { registerInstance } from '../../instances-registry.js';
import { Combobox } from '../../components/combobox/combobox.js';
import { addLeadDataMixin } from './add-lead-data.js';
import { addLeadFieldsMixin } from './add-lead-fields.js';
import { addLeadTableMixin } from './add-lead-table.js';
import { addLeadValidationMixin } from './add-lead-validation.js';
import { addLeadUIMixin } from './add-lead-ui.js';
import { addLeadPhoneFormatterMixin } from './add-lead-phone-formatter.js'; // ✨ NOU

class AddLeadModal {
  constructor() {
    // Singleton check
    if (AddLeadModal.instance) {
      console.warn('⚠️ AddLeadModal is singleton, returning existing instance');
      return AddLeadModal.instance;
    }

    this.debugMode = true;

    AddLeadModal.instance = this;
    this.Combobox = Combobox;
    this.sessionData = sessionData;
    this.eventBus = eventBus;
    this.EVENTS = EVENTS;

    // Apply mixins (✨ adăugat phone formatter)
    Object.assign(this, addLeadDataMixin);
    Object.assign(this, addLeadFieldsMixin);
    Object.assign(this, addLeadTableMixin);
    Object.assign(this, addLeadValidationMixin);
    Object.assign(this, addLeadUIMixin);
    Object.assign(this, addLeadPhoneFormatterMixin); // ✨ NOU

    // State
    this.isInitialized = false;
    this.isModalOpen = false;
    this.currentPhone = '';
    this.selectedCountry = {
      code: 'RO',
      dialCode: '+40',
      flag: 'ro',
      name: 'România',
    };
    this.tableData = [];
    this.selectedRow = null;
    this.actionType = null; // 'new' | 'old_new' | 'old_old'

    // Components
    this.countryCombobox = null;

    // DOM Elements
    this.overlayElement = null;
    this.containerElement = null;
    this.headerElement = null;
    this.loadingElement = null;
    this.countryContainerElement = null;
    this.phoneInputElement = null;
    this.tableContainerElement = null;
    this.tableSectionElement = null;
    this.tableBodyElement = null;
    this.tableFooterElement = null;
    this.nouBtnElement = null;
    this.vechiBtnElement = null;
    this.okBtnElement = null;
    this.cancelBtnElement = null;

    // Timers
    this.validationTimeout = null;

    // Listener flags
    this.areModalListenersSet = false;
    this.areBusListenersSet = false;

    // Apply ListenerTracker mixin
    ListenerTracker.applyTo(this, {
      debugMode: true,
      logPrefix: 'AddLeadModal',
      trackPerformance: false,
    });

    registerInstance('addLeadModal', this, {
      version: '2.0.0',
      description: 'Add lead modal with phone verification and input mask',
      dependencies: ['eventBus', 'dataLoaderExtra', 'combobox'],
    });
  }

  /**
   * Inițializare modal (LAZY - doar la prima deschidere)
   */
  async init() {
    if (this.isInitialized) {
      this.log('⚠️ AddLeadModal deja inițializat');
      return;
    }

    this.log('🚀 Inițializez AddLeadModal...');

    try {
      await this.loadModalCSS();
      await this.loadPhoneLibrary();
      await this.createModal();
      // await this.createOverlay();

      this.setupBusListeners();
      this.setupModalListeners();
      this.initializeCountryCombobox(); // ✨ Include și phone mask

      this.isInitialized = true;
      this.log('✅ AddLeadModal inițializat cu succes');
    } catch (error) {
      this.log.error('Eroare la inițializare', error);
    }
  }

  /**
   * Încarcă CSS-ul dinamic (DOAR o dată)
   */
  async loadModalCSS() {
    if (document.getElementById('addLeadModalCSS')) {
      this.log('✅ CSS deja încărcat');
      return;
    }

    this.log('🎨 Încarc CSS-ul modal...');

    return new Promise((resolve, reject) => {
      const link = document.createElement('link');
      link.id = 'addLeadModalCSS';
      link.rel = 'stylesheet';
      link.href = '/static/css/add_lead/add_lead.css?v=' + Date.now();

      link.onload = () => {
        this.log('✅ CSS încărcat cu succes');
        resolve();
      };

      link.onerror = () => {
        this.log.error('❌ Eroare la încărcarea CSS-ului');
        reject(new Error('Failed to load CSS'));
      };

      document.head.appendChild(link);
    });
  }

  /**
   * Încarcă librăria libphonenumber-js (pentru validare avansată)
   */
  async loadPhoneLibrary() {
    if (window.libphonenumber) {
      this.log('✅ libphonenumber deja încărcat');
      return;
    }

    this.log('📚 Încarc libphonenumber-js...');

    return new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.src =
        'https://cdn.jsdelivr.net/npm/libphonenumber-js@1.10.51/bundle/libphonenumber-js.min.js';

      script.onload = () => {
        this.log('✅ libphonenumber încărcat cu succes');
        resolve();
      };

      script.onerror = () => {
        this.log.error('❌ Eroare la încărcarea libphonenumber');
        reject(new Error('Failed to load libphonenumber'));
      };

      document.head.appendChild(script);
    });
  }

  /**
   * Încarcă template-ul HTML
   */
  async loadModalTemplate() {
    this.log('📄 Încarc template-ul HTML...');

    try {
      const response = await fetch('/static/html/add_lead.html?v=' + Date.now());

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const template = await response.text();
      this.log('✅ Template HTML încărcat cu succes');
      return template;
    } catch (error) {
      this.log.error('Eroare la încărcarea template-ului!', error);
      throw error;
    }
  }

  /**
   * Creează overlay-ul
   */
  // async createOverlay() {
  //   if (this.overlayElement) {
  //     this.log('✅ Overlay deja creat');
  //     return;
  //   }

  //   this.log('🔨 Creez overlay-ul...');
  //   const overlay = document.createElement('div');
  //   overlay.id = 'addLead_Overlay';
  //   overlay.className = 'add-lead-overlay';
  //   document.body.appendChild(overlay);
  //   this.overlayElement = overlay;
  //   this.log('✅ Overlay creat în DOM');
  // }

  /**
   * Creează modal-ul în DOM
   */
  async createModal() {
    this.log('🔨 Creez modal-ul...');

    const template = await this.loadModalTemplate();

    const container = document.createElement('div');
    container.id = 'addLead_container';
    container.className = 'add-lead-container hidden';
    container.innerHTML = template;

    document.body.appendChild(container);

    this.containerElement = container;
    this.headerElement = container.querySelector('#addLead_header');
    this.loadingElement = container.querySelector('#addLead_loading');
    this.countryContainerElement = container.querySelector('#addLead_steag');
    this.phoneInputElement = container.querySelector('#telefon');
    this.tableSectionElement = container.querySelector('#addLead_middle_section');
    this.tableContainerElement = container.querySelector('#addLead_table_container');
    this.tableBodyElement = container.querySelector('#addLead_TableBody');
    this.tableFooterElement = container.querySelector('#addLead_table_footer');
    this.nouBtnElement = container.querySelector('#addLead_Nou');
    this.vechiBtnElement = container.querySelector('#addLead_Vechi');
    this.okBtnElement = container.querySelector('#addLead_Ok');
    this.cancelBtnElement = container.querySelector('#addLead_Cancel');

    this.log('✅ Modal creat în DOM');
  }

  /**
   * Setup bus listeners
   */
  setupBusListeners() {
    if (this.areBusListenersSet) return;

    this.addBusListener(EVENTS.ROW_OPTIONS_CLICKED, (eventData) => {
      if (eventData.data?.rowAction !== 'addLead') return;
      this.openModal(eventData);
    });

    this.addBusListener(EVENTS.EXTRA_DATA_LOAD_COMPLETE, (eventData) =>
      this.handleExtraDataLoaded(eventData)
    );

    this.areBusListenersSet = true;
  }

  /**
   * Setup modal listeners (✨ simplificat - keydown/paste sunt în formatter)
   */
  setupModalListeners() {
    if (this.areModalListenersSet) return;

    this.addClickListener(this.loadingElement, () => this.closeModal());
    this.addClickListener(this.cancelBtnElement, () => this.closeModal());
    this.addClickListener(this.okBtnElement, () => this.handleConfirm());

    this.addClickListener(this.nouBtnElement, () => this.handleNouClick());
    this.addClickListener(this.vechiBtnElement, () => this.handleVechiClick());

    // this.addClickListener(this.overlayElement, (e) => {
    //   if (e.target === this.overlayElement) {
    //     this.closeModal();
    //   }
    // });

    this.areModalListenersSet = true;
  }

  /**
   * Reset complete modal
   */
  resetModal() {
    this.currentPhone = '';
    this.selectedRow = null;
    this.actionType = null;
    this.tableData = [];

    // Clear validation timeout
    if (this.validationTimeout) {
      clearTimeout(this.validationTimeout);
      this.validationTimeout = null;
    }

    // Reset country to Romania
    this.selectedCountry = {
      code: 'RO',
      dialCode: '+40',
      flag: 'ro',
      name: 'România',
    };

    if (this.countryCombobox) {
      this.countryCombobox.setValue('RO', 'România');
      this.countryCombobox.setPrefixIcon(`<span class="fi fi-ro"></span>`);
    }

    // ✨ Reset phone input cu mask
    if (this.phoneInputElement) {
      this.applyPhoneMask('RO');
    }

    // Hide table section
    if (this.tableSectionElement) {
      this.tableSectionElement.classList.add('hidden');
    }

    // Clear table
    this.clearTable();

    // Disable buttons
    this.setButtonState('ok', false);
    this.setButtonState('vechi', false);

    this.log('🔄 Modal resetat complet');
  }

  /**
   * 📊 LOGGING
   */
  log = (() => {
    const fn = (message, data = null) => {
      if (this.debugMode) {
        const now = new Date();
        const ts = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now
          .getMilliseconds()
          .toString()
          .padStart(3, '0')}`;
        const CPN = `ADD_LEAD`.padEnd(15);
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
      const CPN = `ADD_LEAD`.padEnd(15);
      console.error(
        `%c[${ts}] [${CPN}] ${message}`,
        'color: #e74c3c; font-weight: bold;',
        data ?? ''
      );
    };

    return fn;
  })();
}

// Creare și export instanță
const addLeadModal = new AddLeadModal();
export default addLeadModal;
