/**
 * ========== OPTIONS PANEL MANAGER - Manager Modular pentru Panelul de Opțiuni ==========
 * Gestionează toate butoanele din options panel cu arhitectură modulară
 *
 * CARACTERISTICI:
 * ✅ Event-bus integration pentru comunicare cu alte module
 * ✅ ListenerTracker pentru cleanup automat
 * ✅ Instances Registry pentru singleton management
 * ✅ State management pentru enable/disable butoane
 * ✅ Visual feedback și animații
 *
 * @version 1.0.0
 * @author Adelina Trandafir - Avatar Soft SRL
 */

//import '../global-variables.js';
import eventBus, { EVENTS } from '../event-bus/event-bus.js';
import ListenerTracker from '../listener-tracker/listener-tracker-mixin.js';
import { getInstance, registerInstance } from '../instances-registry.js';

/**
 * 🎛️ OPTIONS PANEL MANAGER CLASS
 */
class OptionsManager {
  constructor() {
    // Singleton check
    if (OptionsManager.instance) {
      console.warn('⚠️ OptionsManager is singleton, returning existing instance');
      return OptionsManager.instance;
    }
    this.debugMode = false;

    // 🎯 APLICĂ MIXIN-UL LISTENER TRACKER
    ListenerTracker.applyTo(this, {
      debugMode: this.debugMode || false,
      logPrefix: 'optionsManager',
      trackPerformance: true,
    });

    // 🎛️ CONFIGURAȚIE BUTOANE MODULARĂ
    this.buttonDefinitions = new Map([
      // Format: [buttonId, buttonConfig]
      [
        'select-mode',
        {
          id: 'select-mode',
          selector: '[onclick="toggleSelectMode()"]',
          text: '☑️ Selectează Rânduri',
          action: 'toggleSelectMode',
          eventToEmit: EVENTS.OPTIONS_CHECKBOX_REQUEST,
          enabledByDefault: true,
          requiresData: false,
          requiresSelection: false,
          category: 'selection',
          dependencies: [],
          permissions: ['basic'],
        },
      ],
      [
        'export-data',
        {
          id: 'export-data',
          selector: '[onclick="exportData()"]',
          text: '📤 Export',
          action: 'exportData',
          eventToEmit: EVENTS.OPTIONS_EXPORT_DATA_REQUEST,
          enabledByDefault: false,
          requiresData: true,
          requiresSelection: false,
          category: 'data',
          dependencies: ['tableData'],
          permissions: ['export'],
        },
      ],

      [
        'column-settings',
        {
          id: 'column-settings',
          selector: '[onclick="openColumnSettings()"]',
          text: '⚙️ Coloane',
          action: 'openColumnSettings',
          eventToEmit: EVENTS.OPTIONS_COLUMN_SETTINGS_REQUEST,
          enabledByDefault: true,
          requiresData: false,
          requiresSelection: false,
          category: 'settings',
          dependencies: [],
          permissions: ['basic'],
        },
      ],

      [
        'filter-panel',
        {
          id: 'filter-panel',
          selector: '[onclick="toggleFilterPanel()"]',
          text: '🔍 Filtrare',
          action: 'toggleFilterPanel',
          eventToEmit: EVENTS.OPTIONS_FILTER_SHOW_FILTER_PANEL,
          enabledByDefault: true,
          requiresData: false,
          requiresSelection: false,
          category: 'filtering',
          dependencies: [],
          permissions: ['basic'],
        },
      ],
    ]);

    // 📊 STATE MANAGEMENT
    this.buttonStates = new Map();
    this.buttonElements = new Map();
    this.isInitialized = false;
    this.panelVisible = false;
    this.selectMode = false;

    // 📈 STATISTICS
    this.stats = {
      totalButtons: 0,
      enabledButtons: 0,
      disabledButtons: 0,
      buttonClicks: 0,
      errors: 0,
      toggles: 0,
    };

    // 🔐 PERMISSIONS (mockup - în realitate ar veni din sistem)
    this.userPermissions = ['basic', 'create', 'export', 'admin'];

    // Store singleton instance
    OptionsManager.instance = this;

    // 🎯 AUTO-REGISTER în registry
    registerInstance('optionsManager', this, {
      version: '1.0.0',
      description: 'Modular options manager with event-bus integration',
      dependencies: ['eventBus', 'ListenerTracker'],
    });

    this.log('🎛️ OptionsManager inițializat');
  }

  /**
   * 🚀 INIȚIALIZARE
   */
  init() {
    if (this.isInitialized) {
      console.warn('⚠️ OptionsPanelManager deja inițializat');
      return true;
    }

    try {
      // 📡 Setup event listeners
      this.setupEventListeners();

      // 🔘 Setup button handlers
      this.setupButtonHandlers();

      // 📊 Initialize button states
      this.initializeButtonStates();

      // 🎛️ Setup panel toggle
      this.setupPanelToggle();

      this.isInitialized = true;

      this.log('✅ OptionsPanelManager inițializat cu succes');
      return true;
    } catch (error) {
      this.log.error('❌ Eroare la inițializarea OptionsPanelManager:', error);
      this.stats.errors++;
      return false;
    }
  }

  /**
   * 📡 SETUP EVENT LISTENERS
   */
  setupEventListeners() {
    // 🎛️ PANEL VISIBILITY EVENTS
    this.addBusListener(EVENTS.OPTIONS_SHOW, () => {
      this.showPanel();
    });

    this.addBusListener(EVENTS.OPTIONS_HIDE, () => {
      this.hidePanel();
    });

    // 📊 Enable export button when table data is loaded
    this.addBusListener(EVENTS.TABLE_BUILD_COMPLETE, () => {
      this.updateButtonStatesBasedOnData(getInstance('dataLoader')?.rowsData);
    });

    this.log('📡 Event listeners configurați pentru OptionsPanel');
  }

  /**
   * 🔘 SETUP BUTTON HANDLERS - MODULAR APPROACH
   */
  setupButtonHandlers() {
    const optionsPanel = document.querySelector('.options-panel');
    if (!optionsPanel) {
      this.log.error('❌ Options panel element nu a fost găsit!');
      return;
    }

    this.buttonDefinitions.forEach((config, buttonId) => {
      const element = document.getElementById(buttonId);

      if (element) {
        // 🗑️ Elimină onclick-ul existent pentru control complet
        // element.removeAttribute('onclick');

        // 📝 Adaugă identificatori pentru debugging
        element.setAttribute('data-button-id', buttonId);
        element.setAttribute('data-action', config.action);

        // 🎧 Adaugă click listener cu tracking automat
        this.addClickListener(element, (e) => {
          e.preventDefault();
          e.stopPropagation();

          this.handleButtonClick(buttonId, config, element);
        });

        // 📊 Store element reference
        this.buttonElements.set(buttonId, element);

        this.log(`✅ Handler configurat pentru butonul ${buttonId}`);
      } else {
        console.warn(`⚠️ Element pentru butonul ${buttonId} nu a fost găsit (${config.selector})`);
      }
    });

    this.stats.totalButtons = this.buttonElements.size;
  }

  /**
   * 🔘 HANDLE BUTTON CLICK - UNIFIED HANDLER
   */
  handleButtonClick(buttonId, config, element) {
    try {
      // 🔒 Check permissions
      if (!this.checkPermissions(config.permissions)) {
        console.warn(`🔒 Permisiuni insuficiente pentru ${buttonId}`);
        this.showPermissionError(config.text);
        return;
      }

      // 🔍 Check dependencies
      if (!this.checkDependencies(config.dependencies)) {
        console.warn(`🔗 Dependențe lipsă pentru ${buttonId}`);
        this.showDependencyError(config.text);
        return;
      }

      // 📊 Check data requirements
      if (config.requiresData && !this.hasRequiredData()) {
        console.warn(`📊 Date lipsă pentru ${buttonId}`);
        this.showDataError(config.text);
        return;
      }

      // ✅ Check selection requirements
      if (config.requiresSelection && !this.hasSelection()) {
        console.warn(`✅ Selecție lipsă pentru ${buttonId}`);
        this.showSelectionError(config.text);
        return;
      }

      // 🎯 Execute action
      this.executeButtonAction(buttonId, config, element);

      // 📊 Update stats
      this.stats.buttonClicks++;

      // 🎨 Visual feedback
      this.showButtonFeedback(element, 'success');

      this.log(`🎯 Buton ${buttonId} executat cu succes`);
    } catch (error) {
      this.log.error(`❌ Eroare la execuția butonului ${buttonId}:`, error);
      this.stats.errors++;
      this.showButtonFeedback(element, 'error');
    }
  }

  /**
   * 🎯 EXECUTE BUTTON ACTION - MAIN DISPATCHER
   */
  executeButtonAction(buttonId, config, element) {
    // 📡 Emit event pentru alte module
    // eventBus.emit(config.eventToEmit, {
    //   buttonId,
    //   action: config.action,
    //   element,
    //   timestamp: Date.now(),
    // });

    // 🎯 Execute specific action based on type
    switch (config.action) {
      case 'toggleSelectMode':
        this.handleToggleSelectMode();
        break;

      case 'refreshData':
        this.handleRefreshData();
        break;

      case 'addNew':
        this.handleAddNew();
        break;

      case 'exportData':
        this.handleExportData();
        break;

      case 'openColumnSettings':
        this.handleColumnSettings();
        break;

      case 'toggleFilterPanel':
        this.handleToggleFilterPanel();
        break;

      default:
        console.warn(`⚠️ Acțiune necunoscută: ${config.action}`);
      // this.executeCustomAction(buttonId, config);
    }
  }

  /**
   * 🎯 SPECIFIC ACTION HANDLERS
   */
  handleToggleSelectMode() {
    // Toggle select mode logic
    const currentMode = this.selectMode;
    this.selectMode = !currentMode;

    // Update UI to reflect state
    this.updateSelectModeUI(!currentMode);

    // Il asculta table-controller
    eventBus.emit(EVENTS.ROW_SELECT_TOGGLE, {
      isActive: !currentMode,
      source: 'options-panel',
    });

    this.log(`🎯 Select mode ${!currentMode ? 'activat' : 'dezactivat'}`);
  }

  handleRefreshData() {
    // Trigger data refresh through event bus
    this.log('🔄 Refresh data solicitat prin OptionsPanel');

    // Emit additional events for comprehensive refresh
    eventBus.emit(EVENTS.TABLE_REFRESH_REQUEST, {
      source: 'options-panel',
      timestamp: Date.now(),
    });
  }

  handleAddNew() {
    this.log('➕ Add new solicitat prin OptionsPanel');

    // Could open modal, navigate to form, etc.
    eventBus.emit(EVENTS.ADD_NEW_MODAL_REQUEST, {
      source: 'options-panel',
    });
  }

  handleExportData() {
    this.log('📤 Export data solicitat prin OptionsPanel');

    const dataLoader = getInstance('dataLoader');
    const tableBuilder = getInstance('tableBuilder');

    if (!dataLoader?.rowsData?.length || !tableBuilder?.visibleColumns?.length) {
      console.warn('⚠️ Nu există date pentru export');
      return;
    }

    const columns = tableBuilder.visibleColumns.filter((col) => !col.special);
    const headers = columns.map((col) => col.header);
    const rows = dataLoader.rowsData.map((row) =>
      columns.map((col) => {
        const val = row[col.field];
        return val == null ? '' : String(val).replace(/"/g, '""');
      })
    );

    const csv = [
      headers.map((h) => `"${h}"`).join(','),
      ...rows.map((row) => row.map((cell) => `"${cell}"`).join(',')),
    ].join('\n');

    const bom = '\uFEFF';
    const blob = new Blob([bom + csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `export_${new Date().toISOString().slice(0, 10)}.csv`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);

    this.log(`📤 Export complet: ${rows.length} rânduri`);
  }

  handleColumnSettings() {
    this.log('⚙️ Column settings solicitat prin OptionsPanel');
    window.location.href = '/column-settings';
  }

  handleToggleFilterPanel() {
    const isRightPanelVisible = getInstance('panelManager').isPanelVisible('panel-dreapta');
    this.log(
      '🔍 Filter panel toggle solicitat prin OptionsPanel',
      `Vizibil: ${isRightPanelVisible}`
    );

    if (!isRightPanelVisible) {
      // Il asculta panel-manager/showPanel
      eventBus.emit(EVENTS.PANEL_SHOW_REQUEST, {
        panelId: 'panel-dreapta',
        requestSource: 'filter-panel',
      });
    } else {
      eventBus.emit(EVENTS.PANEL_HIDE_REQUEST, {
        panelId: 'panel-dreapta',
        requestSource: 'filter-panel',
      });
    }
  }

  /**
   * 🔧 CUSTOM ACTION EXECUTOR - PENTRU BUTOANE ADĂUGATE DINAMIC
   */
  // executeCustomAction(buttonId, config) {
  //   // Emit generic event for custom handlers
  //   eventBus.emit(EVENTS.CUSTOM_BUTTON_CLICKED, {
  //     buttonId,
  //     config,
  //     timestamp: Date.now(),
  //   });

  //   this.log(`🔧 Custom action executat pentru ${buttonId}`);
  // }

  /**
   * 📊 INITIALIZE BUTTON STATES
   */
  initializeButtonStates() {
    this.buttonDefinitions.forEach((config, buttonId) => {
      const initialState = {
        enabled: config.enabledByDefault,
        visible: true,
        active: false,
        lastClicked: null,
        clickCount: 0,
      };

      this.buttonStates.set(buttonId, initialState);
      this.applyButtonState(buttonId, initialState);
    });

    this.updateStats();
    this.log('📊 Button states inițializate');
  }

  /**
   * 🔄 UPDATE BUTTON STATES BASED ON DATA
   */
  updateButtonStatesBasedOnData(data) {
    const hasData = data && data.length > 0;

    this.buttonDefinitions.forEach((config, buttonId) => {
      if (config.requiresData) {
        this.setButtonEnabled(buttonId, hasData);
      }
    });

    this.log(`📊 Button states actualizate bazat pe date (hasData: ${hasData})`);
  }

  /**
   * ✅ UPDATE SELECTION DEPENDENT BUTTONS
   */
  updateSelectionDependentButtons(hasSelection) {
    this.buttonDefinitions.forEach((config, buttonId) => {
      if (config.requiresSelection) {
        this.setButtonEnabled(buttonId, hasSelection);
      }
    });

    this.log(`✅ Selection dependent buttons actualizate (hasSelection: ${hasSelection})`);
  }

  /**
   * 🔧 BUTTON STATE MANAGEMENT METHODS
   */
  setButtonEnabled(buttonId, enabled) {
    const state = this.buttonStates.get(buttonId);
    if (state) {
      state.enabled = enabled;
      this.buttonStates.set(buttonId, state);
      this.applyButtonState(buttonId, state);
      this.updateStats();
    }
  }

  setButtonVisible(buttonId, visible) {
    const state = this.buttonStates.get(buttonId);
    if (state) {
      state.visible = visible;
      this.buttonStates.set(buttonId, state);
      this.applyButtonState(buttonId, state);
    }
  }

  setButtonActive(buttonId, active) {
    const state = this.buttonStates.get(buttonId);
    if (state) {
      state.active = active;
      this.buttonStates.set(buttonId, state);
      this.applyButtonState(buttonId, state);
    }
  }

  /**
   * 🎨 APPLY BUTTON STATE TO DOM
   */
  applyButtonState(buttonId, state) {
    const element = this.buttonElements.get(buttonId);
    if (!element) return;

    // Enable/Disable
    if (state.enabled) {
      element.removeAttribute('disabled');
      element.classList.remove('disabled');
    } else {
      element.setAttribute('disabled', 'true');
      element.classList.add('disabled');
    }

    // Show/Hide
    if (state.visible) {
      element.style.display = '';
      element.classList.remove('hidden');
    } else {
      element.style.display = 'none';
      element.classList.add('hidden');
    }

    // Active state
    if (state.active) {
      element.classList.add('active');
      element.setAttribute('aria-pressed', 'true');
    } else {
      element.classList.remove('active');
      element.setAttribute('aria-pressed', 'false');
    }
  }

  /**
   * 🎛️ PANEL TOGGLE FUNCTIONALITY
   */
  setupPanelToggle() {
    const trigger = document.querySelector('.options-trigger');
    const dropdown = document.querySelector('.options-dropdown');

    if (trigger && dropdown) {
      // this.addClickListener(trigger, (e) => {
      //   e.preventDefault();
      //   e.stopPropagation();
      //   this.togglePanel();
      // });

      // Click outside to close
      // this.addDOMListener(document, 'click', (e) => {
      //   if (!e.target.closest('.options-panel')) {
      //     this.hidePanel();
      //   }
      // });

      this.log('🎛️ Panel toggle configurat');
    }
  }

  togglePanel() {
    this.panelVisible = !this.panelVisible;
    this.stats.toggles++;

    if (this.panelVisible) {
      this.showPanel();
    } else {
      this.hidePanel();
    }
  }

  showPanel() {
    const dropdown = document.querySelector('.options-dropdown');
    if (dropdown) {
      dropdown.classList.add('visible');
      this.panelVisible = true;

      eventBus.emit(EVENTS.OPTIONS_SHOW, {
        timestamp: Date.now(),
      });
    }
  }

  hidePanel() {
    const dropdown = document.querySelector('.options-dropdown');
    if (dropdown) {
      dropdown.classList.remove('visible');
      this.panelVisible = false;

      eventBus.emit(EVENTS.OPTIONS_HIDE, {
        timestamp: Date.now(),
      });
    }
  }

  /**
   * 🔍 VALIDATION METHODS
   */
  checkPermissions(requiredPermissions) {
    if (!requiredPermissions || requiredPermissions.length === 0) return true;

    return requiredPermissions.some((permission) => this.userPermissions.includes(permission));
  }

  checkDependencies(dependencies) {
    if (!dependencies || dependencies.length === 0) return true;

    return dependencies.every((dep) => {
      switch (dep) {
        case 'tableData':
          return getInstance('dataLoader')?.rowsData?.length > 0;
        case 'filterManager':
          return window.filterManager && window.filterManager.isInitialized;
        default:
          return window[dep] !== undefined;
      }
    });
  }

  hasRequiredData() {
    return getInstance('dataLoader')?.rowsData?.length > 0;
  }

  hasSelection() {
    // Check for selected rows in various ways
    const selectedRows = document.querySelectorAll('.table-row.selected');
    return selectedRows.length > 0 || window.selectedRowData;
  }

  /**
   * 🎨 VISUAL FEEDBACK METHODS
   */
  showButtonFeedback(element, type) {
    element.classList.add(`feedback-${type}`);

    this.addTimeout(() => {
      element.classList.remove(`feedback-${type}`);
    }, 300);
  }

  showPermissionError(buttonText) {
    console.warn(`🔒 Acces restricționat la: ${buttonText}`);
    // Could show toast or modal
  }

  showDependencyError(buttonText) {
    console.warn(`🔗 Dependențe lipsă pentru: ${buttonText}`);
  }

  showDataError(buttonText) {
    console.warn(`📊 Date necesare pentru: ${buttonText}`);
  }

  showSelectionError(buttonText) {
    console.warn(`✅ Selecție necesară pentru: ${buttonText}`);
  }

  /**
   * 🎨 UI UPDATE METHODS
   */
  updateSelectModeUI(isActive) {
    const button = this.buttonElements.get('select-mode');
    if (button) {
      this.setButtonActive('select-mode', isActive);

      // Update button text based on state
      const config = this.buttonDefinitions.get('select-mode');
      button.textContent = isActive ? '☑️ Anulează Selecție' : config.text;
    }
  }

  /**
   * 📊 STATISTICS AND STATE METHODS
   */
  updateStats() {
    let enabled = 0;
    let disabled = 0;

    this.buttonStates.forEach((state) => {
      if (state.enabled) enabled++;
      else disabled++;
    });

    this.stats.enabledButtons = enabled;
    this.stats.disabledButtons = disabled;
  }

  refreshButtonStates() {
    // Re-evaluate all button states
    this.updateButtonStatesBasedOnData(window.tableData);
    this.updateSelectionDependentButtons(this.hasSelection());

    this.log('🔄 Button states refreshed');
  }

  enableButtonsRequiringTable() {
    this.buttonDefinitions.forEach((config, buttonId) => {
      if (config.dependencies.includes('tableData')) {
        this.setButtonEnabled(buttonId, true);
      }
    });
  }

  /**
   * 🗑️ CLEANUP
   */
  destroy() {
    this.log('🗑️ Destrucție OptionsPanelManager...');

    // Hide panel
    this.hidePanel();

    // Cleanup automat prin ListenerTracker
    const cleanupStats = this.cleanupAllListeners();

    // Clear maps
    this.buttonDefinitions.clear();
    this.buttonStates.clear();
    this.buttonElements.clear();

    // Clear singleton
    OptionsManager.instance = null;

    // Final event
    eventBus.emit(EVENTS.OPTIONS_PANEL_DESTROYED, {
      cleanupStats,
      finalStats: this.getStats(),
    });

    this.log('✅ OptionsPanelManager eliminat complet', cleanupStats);
  }
  log = (() => {
    const fn = (message, data = null) => {
      if (this.debugMode) {
        const now = new Date();
        const ts = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now
          .getMilliseconds()
          .toString()
          .padStart(3, '0')}`;
        const CPN = 'OptionsManager'.padEnd(15);
        console.log(
          `%c[${ts}] [${CPN}] ${message}`,
          'color: #bc4ea4ff; font-weight: bold;',
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
      const CPN = 'OptionsManager'.padEnd(15);
      console.error(
        `%c[${ts}] [${CPN}] ${message}`,
        'color: #ff3333; font-weight: bold;',
        data ?? ''
      );
    };

    return fn;
  })(this);
}

// 🎯 CREEAZĂ INSTANȚA SINGLETON
const optionsManager = new OptionsManager();

// 🌍 EXPORT PENTRU MODULE
export default optionsManager;
