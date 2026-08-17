// filepath: /static/js/dashboard/feedback-modal/feedback-manager.js
/**
 * 💬 FEEDBACK MODAL MANAGER
 * Gestionează modal-ul de adăugare feedback pentru clienți
 *
 * @version 2.0.0
 * @author Adelina Trandafir - Avatar Soft SRL
 */

import eventBus, { EVENTS } from '../../event-bus/event-bus.js';
import sessionData from '../../session/session-data.js';
import ListenerTracker from '../../listener-tracker/listener-tracker-mixin.js';
import { registerInstance } from '../../instances-registry.js';
import { CalendarManager } from '../../components/calendar/calendar-manager.js';
import { Combobox } from '../../components/combobox/combobox.js';
import { feedbackDataMixin } from './feedback-data.js';
import { feedbackEditorMixin } from './feedback-editor.js';
import { feedbackFieldsMixin } from './feedback-fields.js';
import { feedbackFormMixin } from './feedback-form.js';
import { feedbackUIMixin } from './feedback-ui.js';

class FeedbackModal {
  constructor() {
    // Singleton check
    if (FeedbackModal.instance) {
      console.warn('⚠️ FeedbackModal is singleton, returning existing instance');
      return FeedbackModal.instance;
    }

    FeedbackModal.instance = this;
    this.CalendarManager = CalendarManager;
    this.Combobox = Combobox;
    this.sessionData = sessionData;
    this.eventBus = eventBus;
    this.EVENTS = EVENTS;

    Object.assign(this, feedbackDataMixin);
    Object.assign(this, feedbackEditorMixin);
    Object.assign(this, feedbackFieldsMixin);
    Object.assign(this, feedbackFormMixin);
    Object.assign(this, feedbackUIMixin);

    this.isInitialized = false;
    this.currentRowId = null;
    this.statusData = [];
    this.statusCombobox = null;
    this.selectedStatus = null;
    this.calendarManager = null;

    this.calendarElement = null;
    this.calendarContainerElement = null;
    this.modalElement = null;
    this.overlayElement = null;
    this.headerElement = null;
    this.footerElement = null;
    this.feedbackElement = null;
    this.saveBtnElement = null;
    this.counterElement = null;
    this.cancelBtnElement = null;
    this.closeBtnElement = null;
    this.toolBarElement = null;
    this.colorPickerElement = null;
    this.statusElement = null;
    this.dateElement = null;

    this.areModalListenersSet = false;
    this.areBusListenersSet = false;
    // Editor state
    this.editorContent = '';

    // Spell check state
    this.spellCheckBannerDismissed =
      localStorage.getItem('feedback-spell-banner-dismissed') === 'true';

    // 🎯 APLICĂ MIXIN-UL LISTENER TRACKER
    ListenerTracker.applyTo(this, {
      debugMode: false,
      logPrefix: 'FeedbackModal',
      trackPerformance: true,
    });

    registerInstance('feedbackModal', this, {
      version: '1.0.0',
      description: 'Feedback modal with lazy loading',
      dependencies: ['eventBus', 'dataLoaderExtra', 'calendarManager', 'combobox'],
    });
  }

  /**
   * Inițializare modal (LAZY - doar la prima deschidere)
   */
  async init() {
    if (this.isInitialized) {
      this.log('⚠️ FeedbackModal deja inițializat');
      return;
    }

    this.log('🚀 Inițializez FeedbackModal...');

    try {
      await this.loadModalCSS();
      await this.createModal();
      await this.createOverlay();

      this.calendarManager = new this.CalendarManager();

      this.calendarContainerElement = this.modalElement.querySelector('#g_DataRecontactare');

      this.setupBusListeners();
      this.setupModalEventsListeners();
      this.initializeStatusCombobox();
      this.setupToolbarListeners();
      this.loadStatusData();

      this.isInitialized = true;
      this.log('✅ FeedbackModal inițializat cu succes');
    } catch (error) {
      this.log.error('Eroare la inițializare', error);
    }
  }

  /**
   * Încarcă CSS-ul dinamic (DOAR o dată)
   */
  async loadModalCSS() {
    // Verifică dacă CSS-ul e deja încărcat
    if (document.getElementById('feedbackModalCSS')) {
      this.log('✅ CSS deja încărcat');
      return;
    }

    this.log('🎨 Încarc CSS-ul modal...');

    return new Promise((resolve, reject) => {
      const link = document.createElement('link');
      link.id = 'feedbackModalCSS';
      link.rel = 'stylesheet';
      link.href = '/static/css/feedback_modal.css?v=' + Date.now();

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
   * Încarcă template-ul HTML din fișier separat
   */
  async loadModalTemplate() {
    this.log('📄 Încarc template-ul HTML...');

    try {
      const response = await fetch('/static/html/feedback_modal.html?v=' + Date.now());

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

  async createOverlay() {
    // Verifică dacă overlay-ul e deja creat
    if (this.overlayElement) {
      this.log('✅ Overlay deja creat');
      return;
    }

    this.log('🔨 Creez overlay-ul...');
    const overlay = document.createElement('div');
    overlay.id = 'feedbackModalOverlay';
    overlay.className = 'feedback-modal-overlay hidden';
    document.body.appendChild(overlay);
    this.overlayElement = overlay;
    this.log('✅ Overlay creat în DOM');
  }

  /**
   * Creează modal-ul în DOM
   */
  async createModal() {
    this.log('🔨 Creez modal-ul...');

    // Încarcă template-ul
    const template = await this.loadModalTemplate();

    const modal = document.createElement('div');
    modal.id = 'feedbackModal';
    modal.className = 'feedback-modal-container hidden';
    modal.innerHTML = template;

    document.body.appendChild(modal);

    this.modalElement = modal;
    this.headerElement = this.modalElement.querySelector('.feedback-modal-header');
    this.footerElement = this.modalElement.querySelector('.feedback-modal-footer');
    this.feedbackElement = this.modalElement.querySelector('#feedback-editor');
    this.saveBtnElement = this.modalElement.querySelector('#feedback-save-btn');
    this.counterElement = this.modalElement.querySelector('#feedback-char-counter');
    this.closeBtnElement = this.modalElement.querySelector('#feedback-close-btn');
    this.cancelBtnElement = this.modalElement.querySelector('#feedback-cancel-btn');
    this.toolBarElement = this.modalElement.querySelector('#feedback-toolbar');
    this.colorPickerElement = this.modalElement.querySelector('#feedback-color-picker');
    this.statusElement = this.modalElement.querySelector('#feedback-status-container');
    this.dateElement = this.modalElement.querySelector('#g_DataRecontactare');
    this.calendarElement = this.dateElement.querySelector('#DataRecontactare'); // input-ul calendarului

    this.log('✅ Modal creat în DOM');
  }

  /**
   * Verifică dacă modal-ul este deschis
   * @returns {boolean} true dacă modal-ul e deschis, false altfel
   */
  isModalOpen() {
    if (!this.modalElement) {
      return false;
    }

    const isOpen = this.modalElement.classList.contains('active');
    return isOpen;
  }

  /**
   * Setează starea de loading pentru butonul de salvare
   * @param {boolean} loading - true pentru a afișa loading, false pentru a ascunde
   */
  setLoadingState(loading) {
    if (!this.saveBtnElement) {
      this.log.error('❌ Save button nu există');
      return;
    }

    if (loading) {
      // Salvează textul original dacă nu e deja salvat
      if (!this.saveBtnElement.dataset.originalText) {
        this.saveBtnElement.dataset.originalText = this.saveBtnElement.textContent;
      }

      this.saveBtnElement.disabled = true;
      this.saveBtnElement.textContent = '💾 Se salvează...';
      this.saveBtnElement.classList.add('loading');

      this.log('⏳ Loading activat');
    } else {
      // Restaurează textul original
      const originalText = this.saveBtnElement.dataset.originalText || '💾 Salvează';

      this.saveBtnElement.disabled = false;
      this.saveBtnElement.textContent = originalText;
      this.saveBtnElement.classList.remove('loading');

      this.log('✅ Loading dezactivat');
    }
  }

  setupModalEventsListeners() {
    if (this.areModalListenersSet) return;

    const dismissBtn = this.modalElement.querySelector('.spell-check-dismiss');

    this.addClickListener(this.closeBtnElement, () => this.closeModal());
    this.addClickListener(this.cancelBtnElement, () => this.closeModal());
    this.addClickListener(this.saveBtnElement, () => this.handleSave());
    this.addClickListener(this.overlayElement, (e) => {
      if (e.target === this.overlayElement) {
        this.closeModal();
      }
    });

    if (dismissBtn) {
      this.addClickListener(dismissBtn, () => this.dismissSpellCheckBanner());
    }

    this.addDOMListener(this.feedbackElement, 'input', () => this.handleEditorInput());

    this.setupEditorListeners();
    this.areModalListenersSet = true;
  }

  setupBusListeners() {
    if (this.areBusListenersSet) return;
    this.addBusListener(EVENTS.ROW_OPTIONS_CLICKED, (eventData) => {
      if (eventData.data?.rowAction !== 'feedback') return;
      this.openModal(eventData);
    });

    this.addBusListener(EVENTS.EXTRA_DATA_LOAD_COMPLETE, (eventData) =>
      this.handleExtraDataLoaded(eventData)
    );

    this.areBusListenersSet = true;
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
        const CPN = `FEEDBACK`.padEnd(15);
        console.log(
          `%c[${ts}] [${CPN}] ${message}`,
          'color: #6c0296ff; font-weight: bold;',
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
      const CPN = `FEEDBACK`.padEnd(15);
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
const feedbackModal = new FeedbackModal();
export default feedbackModal;
