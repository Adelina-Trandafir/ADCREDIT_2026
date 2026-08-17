// js/components/dashboard/details-panel-baza/details-panel-baza-manager.js
/**
 * ========== DETAILS PANEL MANAGER - Controller principal pentru panoul de detalii ==========
 * Orchestrează toate funcționalitățile panelului și coordonează modulele specializate
 *
 * FUNCȚIONALITĂȚI:
 * ✅ Inițializare și setup panel
 * ✅ Gestionare evenimente și interacțiuni
 * ✅ Orchestrare deschidere/închidere panel
 * ✅ Coordinare populare formular
 * ✅ Gestionare salvare/anulare
 * ✅ Integrare cu toate modulele
 *
 * @version 2.0.0 - Refactorizat și modularizat
 */

//import '../../global-variables.js';
import eventBus, { EVENTS } from '../../event-bus/event-bus.js';
import ListenerTracker from '../../listener-tracker/listener-tracker-mixin.js';
import sessionData from '../../session/session-data.js';
import { registerInstance, getInstance } from '../../instances-registry.js';

// Import FeedbackModal instance
import feedbackModal from '../feedback-modal/feedback-manager.js';

// Import componente
import { CalendarManager } from '../../components/calendar/calendar-manager.js';
import { Combobox } from '../../components/combobox/combobox.js';
import { TreeView } from '../../components/treeview/treeview.js';
import { PhoneToolsLight } from '../../components/phone/phone-tools-light.js';
//import { CnpToolsLight } from '../../components/cnp/cnp-tools-light.js';
import { NationalIdTools } from '../../components/national-id/national-id-tools.js';

// Import module specializate existente
import { PanelLoaderMixin } from './details-panel-baza-loader.js';
import { FeedbackManagerMixin } from './details-panel-baza-feedback.js';
import { UtilsMixin } from './details-panel-baza-utils.js';
import { FormManagerMixin } from './details-panel-baza-form.js';
import { PanelUIMixin } from './details-panel-baza-ui.js';
import { DataProcessorsMixin } from './details-panel-baza-data.js';

/**
 * DETAILS PANEL - Clasa principală
 */
class DetailsPanelBaza {
  constructor() {
    // Singleton pattern
    if (DetailsPanelBaza.instance) {
      console.warn('⚠️ detailsPanelBazaManager is singleton');
      return DetailsPanelBaza.instance;
    }

    this.Combobox = Combobox;
    this.TreeView = TreeView;
    this.PhoneTools = PhoneToolsLight;
    this.NationalID = NationalIdTools;

    this.eventBus = eventBus;
    this.EVENTS = EVENTS;
    this.feedbackModal = feedbackModal;
    this.sessionData = sessionData;
    this.getInstance = getInstance;
    this.ListenerTracker = ListenerTracker;

    // 🎯 APLICĂ PANEL MIXINS
    Object.assign(this, PanelLoaderMixin);
    Object.assign(this, FeedbackManagerMixin);
    Object.assign(this, UtilsMixin);
    Object.assign(this, FormManagerMixin);
    Object.assign(this, PanelUIMixin);
    Object.assign(this, DataProcessorsMixin);

    // Configurare inițială
    this.debugMode = true;

    // Aplică ListenerTracker mixin pentru cleanup automat
    ListenerTracker.applyTo(this, {
      debugMode: this.debugMode || false,
      logPrefix: 'detailsPanelBaza',
      trackPerformance: false,
    });

    // State management
    this.isInitialized = false;
    this.isVisible = false;

    // this.overlayElement = null;
    this.currentRowElement = null;
    this.oldRowElement = null;
    this.formElement = null;
    this.panelElement = null;
    this.saveButton = null;
    this.cancelButton = null;
    this.addFeedbackBtnElement = null;
    this.sendMailBtnElement = null;
    this.headerElement = null;

    this.tipDeschidere = '';
    this.currentRowId = null;
    this.currentRowData = null;
    this.originalData = null;

    this.department = null;
    this.feedbackCache = new Map();

    this.isDirty = false;
    this.openOnSingleClick = false;
    this.areBusListenersSet = false;
    this.areDOMListenersSet = false;

    // Configurare panel
    this.config = {
      panelHeight: 200,
      animationDuration: 300,
      cacheTimeout: 5 * 60 * 1000, // 5 minute
      maxCacheSize: 100,
      cleanupInterval: 60 * 1000, // 1 minute

      fields: [
        // Câmpuri simple (input text)
        { id: 'NumeClient', label: 'Nume Client', type: 'text', position: 'left' },
        // { id: 'CNPClient', label: 'CNP Client', type: 'text', position: 'left' },
        // { id: 'TelefonClient', label: 'Telefon Client', type: 'text', position: 'left' },
        { id: 'EmailClient', label: 'Email Client', type: 'email', position: 'left' },

        // Input CNP Client cu validare
        {
          id: 'CNPClient',
          label: 'CNP Client',
          type: 'national-id',
          position: 'left',
          //validate: (value) => this.CnpTools.validate(value),
        },

        // Input Telefon Client cu validare
        {
          id: 'TelefonClient',
          label: 'Telefon Client',
          type: 'phone',
        },

        // ComboBox Județ
        {
          id: 'JudetClient',
          label: 'Județ Client',
          type: 'combo',
          position: 'left',
          valueField: 'IdJudet',
          textField: 'JudetClient',
        },

        // Dată
        {
          id: 'DataPrimire',
          label: 'Data Primire',
          type: 'datetime-local',
          position: 'center',
          dateConfig: {
            defaultTime: '09:00',
            timeStep: 15,
            minTime: '08:00',
            maxTime: '18:00',
            allowWeekends: false,
            allowPast: false,
            allowFuture: true,
            businessHoursOnly: false,
            validationRules: [],
            customMessages: {},
          },
        },

        // TreeView Consultant
        {
          id: 'NumeConsultant',
          label: 'Consultant SVN',
          type: 'tree',
          position: 'center',
          twoRows: false,
          valueField: 'IdConsultant',
          textField: 'NumeConsultant',
        },

        // TreeView Sursă Lead
        {
          id: 'NumeAgent',
          label: 'Sursă / Agent',
          type: 'tree',
          position: 'center',
          showTwoRowsInInput: true,
          valueField: 'IdAgent',
          textField: 'NumeAgent',
          valueSecondaryField: 'IdSursa',
          textSecondaryField: 'Sursa',
        },

        // Caption / readonly
        // { id: 'NumeAgent', label: 'Nume Agent', type: 'caption', position: 'center' },
        { id: 'aTelefon', label: 'Tel Agent', type: 'caption', position: 'center' },
        { id: 'aMail', label: 'Email Agent', type: 'caption', position: 'center' },
      ],
    };

    // Components
    this.components = {
      comboboxJudet: null,
      treeviewSursa: null,
      treeviewConsultant: null,
      phoneClient: null,
      formInputs: new Map(),
      dateInputs: new Map(),
    };

    // Statistics
    this.stats = {
      opens: 0,
      saves: 0,
      cancels: 0,
      feedbackLoads: 0,
      cacheHits: 0,
    };

    // Inițializează managerii specializați
    this.calendarManager = new CalendarManager();

    DetailsPanelBaza.instance = this;
    registerInstance('detailsPanelBaza', this);
  }

  // ============================================================================
  // 🚀 INIȚIALIZARE ȘI SETUP
  // ============================================================================
  async init() {
    if (this.isInitialized) {
      this.log('⚠️ detailsPanelBazaManager deja inițializat');
      return;
    }

    try {
      this.log('🚀 Inițializez detailsPanelBazaManager...');
      await this.createPanel();

      this.department = sessionData.get('Department');
      this.setupBusListeners();
      this.loadInitialData();

      this.isInitialized = true;
      this.log('✅ detailsPanelBazaManager inițializat cu succes');
    } catch (error) {
      this.log.error('Eroare la inițializare', error);
    }
  }

  async createPanel() {
    this.log('📦 Creez elementul panel (ascuns implicit)');

    await this.loadPanelStyles();
    const template = await this.loadPanelTemplate();

    document.body.insertAdjacentHTML('beforeend', template);
    this.panelElement = document.getElementById('detailsPanelBaza');
    //this.overlayElement = document.getElementById('detailsPanelBazaOverlay');
    this.formElement = this.panelElement.querySelector('#detailsPanelBazaForm');
    this.headerElement = this.panelElement.querySelector('#detailsPanelBazaHeader');

    if (!this.panelElement || !this.formElement) {
      this.log.error('Eroare la inițializare panel - elemente lipsă');
      return;
    }

    this.saveButton = this.panelElement.querySelector('#detailsPanelBazaSaveBtn');
    this.cancelButton = this.panelElement.querySelector('#detailsPanelBazaCancelBtn');
    this.addFeedbackBtnElement = this.formElement.querySelector('#addFeedbackBtn');
    this.sendMailBtnElement = this.formElement.querySelector('#sendMailBtn');

    // Inițializează componentele formularului
    this.setupFormComponents();
    //this.setupButtons();
    this.log('✅ Panel creat și ascuns în DOM');
  }

  setupBusListeners() {
    if (this.areBusListenersSet) return;
    this.addBusListener(EVENTS.ROW_CLICKED, (data) => this.handleRowClick(data));
    this.addBusListener(EVENTS.ROW_DOUBLE_CLICKED, (data) => this.handleRowClick(data));

    this.addBusListener(EVENTS.ROW_OPTIONS_CLICKED, (data) => this.handleRowClick(data));

    this.addBusListener(EVENTS.DATA_REFRESH_COMPLETE, () => this.handleDataRefresh());
    this.addBusListener(EVENTS.TABLE_RESIZE, () => this.handleResize());
    this.addBusListener(EVENTS.EXTRA_DATA_LOAD_COMPLETE, (eventData) =>
      this.handleExtraDataLoaded(eventData)
    );
    this.addBusListener(EVENTS.EXTRA_DATA_REFRESH_COMPLETE, (eventData) =>
      this.handleExtraDataLoaded(eventData)
    );

    this.addBusListener(EVENTS.DETAILS_PANEL_FEEDBACK_SAVED, (data) => {
      this.handleFeedbackSaved(data);
    });

    // Listener pentru selecția de dată din calendar
    this.addBusListener(EVENTS.CALENDAR_DATE_SELECTED, () => (this.isDirty = true));
    this.addBusListener(EVENTS.CALENDAR_DATE_CLEARED, () => (this.isDirty = true));

    this.addBusListener(EVENTS.ADAUGA_LEAD_INIT, (data) => this.handleAdaugaLeadInit(data));

    this.areBusListenersSet = true;
  }

  setupDOMListeners() {
    if (this.areDOMListenersSet) return;

    this.addDOMListener(window, 'keydown', (e) => {
      if (!this.isVisible) return;

      if (e.key === 'Escape') {
        // Verifică dacă există elemente custom deschis
        for (const compKey in this.components) {
          const component = this.components[compKey];
          if (component && component.isVisible) {
            return;
          }
        }

        // Previne alte handler-e ESC doar dacă panelul e modal
        if (this.disableTable) {
          e.stopPropagation();
          e.preventDefault();
        }
        // StateManager.cancelChanges(this);
      }

      if (e.ctrlKey && e.key === 's') {
        e.preventDefault();
        // StateManager.saveChanges(this);
      }
    });

    this.addClickListener(this.addFeedbackBtnElement, () => this.openModalFeedback());
    this.addClickListener(this.sendMailBtnElement, () => this.handleSendMail());

    this.addClickListener(this.saveButton, () => this.saveChanges());
    this.addClickListener(this.cancelButton, () => {
      // this.disableAllControls();
      // this.clearForm();
      this.closeModal();
    });

    // Click pe overlay închide panelul (doar dacă e modal)
    // if (this.overlayElement) {
    //   this.addClickListener(this.overlayElement, (e) => {
    //     if (e.target === this.overlayElement) {
    //       e.preventDefault();
    //       e.stopPropagation();
    //     }
    //   });
    // }
    this.areDOMListenersSet = true;
  }

  clearDOMListeners() {
    if (!this.areDOMListenersSet) {
      this.log('⚠️ Nu există DOM listeners de curățat');
      return;
    }

    this.log('🧹 Curăț DOM listeners...');

    const elementsToClean = [
      { element: window, name: 'Window' },
      // { element: this.overlayElement, name: 'Overlay' },
      { element: this.addFeedbackBtnElement, name: 'AddFeedbackBtn' },
      { element: this.sendMailBtnElement, name: 'SendMailBtn' },
      { element: this.saveButton, name: 'SaveButton' },
      { element: this.cancelButton, name: 'CancelButton' },
    ];

    let totalRemoved = 0;

    elementsToClean.forEach(({ element, name }) => {
      if (element) {
        // Elimină TOȚI listenerii de pe element (trimite null la eventType)
        const result = this.removeDOMListener(element, null);
        totalRemoved += result.removedCount;

        if (result.removedCount > 0) {
          this.log(
            `🗑️ ${name}: ${result.removedCount} listeners eliminați [${result.removedEventTypes.join(', ')}]`
          );
        }
      }
    });

    this.areDOMListenersSet = false;
    this.log(`✅ DOM listeners curățați (total: ${totalRemoved})`);
  }

  // ============================================================================
  // 🎯 GESTIONAREA INTERACȚIUNILOR
  // ============================================================================
  async handleAdaugaLeadInit(data) {
    this.log('🆕 Inițializare Adaugă Lead:', data);
    this.isDirty = true;
    this.tipDeschidere = data.data.tipAdaugare;
    const telefonAdaugat = data.data.telefon;
    this.clearForm();

    if (this.tipDeschidere === 'leadNou') {
      this.log('🆕 Lead nou-nouț, resetez toate câmpurile');
      // Adauga in campul telefon din config fields
      this.config.fields.forEach((field) => {
        if (field.id === 'TelefonClient') {
          const input = this.components.formInputs.get(field.id);
          if (input) {
            input.value = telefonAdaugat || '';
          }
        }
      });
    } else if (this.tipDeschidere === 'leadVechiNou') {
      this.log('🆕 Lead vechi, populare parțială a formularului');
      this.telefonInput.value = telefonAdaugat || '';
    } else if (this.tipDeschidere === 'leadVechiVechi') {
      // Populează doar câmpurile disponibile în leadVechiNou
      for (const field of this.config.fields) {
        if (data.leadVechiNou.hasOwnProperty(field.id)) {
          const input = this.components.formInputs.get(field.id);
          if (input) {
            input.value = data.leadVechiNou[field.id] || '';
          }
        }
      }
    }
    this.openModal();
  }

  async handleRowClick(eventData) {
    this.log('🖱️ Row was activated by:', eventData.eventName);

    if (eventData.data.rowAction == 'select' && !this.openOnSingleClick) return;
    if (eventData.data.rowAction == 'feedback' || eventData.data.rowAction == 'addLead') return;

    // if (this.oldRowElement) {
    //   this.animationManager.getComponents().rowHighlighter.clearHighlight();
    //   this.oldRowElement = null;
    // }

    const { rowElement, rowId, rowIndex } = eventData.data;

    this.disableTable = true;

    // Logica pentru deschiderea panelului ca footer de tabel
    try {
      if (!this.isVisible) {
        await this.openPanel(rowElement, rowId, rowIndex);
        //this.enableAllControls();
        this.oldRowElement = rowElement;
      } else {
        await this.populatePanel(rowElement, rowId, rowIndex);
        this.oldRowElement = rowElement;
      }
    } catch (error) {
      this.log.error('Eroare la deschiderea panelului', error);
    }
  }

  // ============================================================================
  // 🎯 EVENT HANDLERS
  // ============================================================================
  handleDataRefresh() {
    if (this.isVisible) {
      this.log('⚠️ Date actualizate, închid panelul');
      StateManager.closePanel(this);
    }
  }

  handleResize() {
    if (this.isVisible && this.currentRowElement) {
      this.animationManager.getComponents().bottomPositioner.adjustBottomPanel();
      this.log('🔍 Resize detectat, panel ajustat');
    }
  }

  onJudetSelect(value, text) {
    this.log(`Județ selectat: ${text} (${value})`);
    this.markDirty();
  }

  onSursaSelect(value, text, parentId) {
    this.log(`Sursă selectată: ${text} (${value}) - Parent: ${parentId}`);
    this.markDirty();
  }

  // ============================================================================
  // 📝 INCARCAREA DATELOR INITIALE
  // ============================================================================
  loadInitialData() {
    this.log('📥 Cer datele inițiale prin DataLoaderExtra cu loading states...');
    const department = sessionData.get('Department');
    if (!department) {
      this.log.error('⚠️ Departamentul nu este setat în sessionData');
      return;
    }

    const IdConsultant = sessionData.get('IdConsultant');
    if (!IdConsultant) {
      this.log.error('⚠️ IdConsultant nu este setat în sessionData');
      return;
    }

    try {
      // Emit cereri pentru date inițiale
      this.log('📤 Emit cerere pentru județe...');
      eventBus.emit(EVENTS.EXTRA_DATA_LOAD_START, {
        endpoint: 'get_judete',
        requestType: 'judete',
        cache: true,
        timeout: 10000,
      });

      this.log('📤 Emit cerere pentru surse...');
      eventBus.emit(EVENTS.EXTRA_DATA_LOAD_START, {
        endpoint: 'get_surse_agenti',
        requestType: 'surse_agenti',
        cache: true,
        timeout: 10000,
        department: department,
      });

      this.log('📤 Emit cerere pentru consultanti...');
      eventBus.emit(EVENTS.EXTRA_DATA_LOAD_START, {
        endpoint: 'get_consultanti',
        requestType: 'consultanti',
        cache: true,
        timeout: 10000,
        IdConsultant: IdConsultant,
      });

      this.log('✅ Cereri emise pentru date inițiale');
    } catch (error) {
      this.log.error('⌫ Eroare la emiterea cererilor pentru date inițiale', error);
    }
  }

  // ============================================================================
  // 📊 STATISTICS & MANAGEMENT
  // ============================================================================
  getStats() {
    return {
      ...this.stats,
      feedbackStats: this.feedbackService.getStats(),
      isExpanded: this.isVisible,
      isDirty: this.isDirty,
      isModalEnabled: this.disableTable,
      hasModalOverlay: !!this.modalOverlay,
    };
  }

  destroy() {
    if (this.isVisible) {
      this.closePanel(this);
    }

    this.cleanupModalOverlay(this);
    this.cleanup();
    this.clearAllListeners();

    this.log('🗑️ detailsPanelBazaManager distrus');
  }

  // ============================================================================
  // 📊 LOGGING
  // ============================================================================
  log = (() => {
    const fn = (message, data = null) => {
      if (this.debugMode) {
        const now = new Date();
        const ts = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now
          .getMilliseconds()
          .toString()
          .padStart(3, '0')}`;
        const CPN = 'detailsPanelBaza'.padEnd(15);
        console.log(
          `%c[${ts}] [${CPN}] ${message}`,
          'color: #9b59b6; font-weight: bold;',
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
      const CPN = 'detailsPanelBaza'.padEnd(15);
      console.error(
        `%c[${ts}] [${CPN}] ${message}`,
        'color: #e74c3c; font-weight: bold;',
        data ?? ''
      );
    };

    return fn;
  })();
}

// Creează și inițializează instanța singleton
const detailsPanelBaza = new DetailsPanelBaza();

export default detailsPanelBaza;
