import eventBus, { EVENTS } from '../event-bus/event-bus.js';
import ListenerTracker from '../listener-tracker/listener-tracker-mixin.js';
import filterManager from './filter/filter-manager.js';
import { getInstance, registerInstance } from '../instances-registry.js';

/**
 *
 *
 * @class RGYStats
 * @description Manager principal pentru statistici în dashboard
 * - Singleton
 * - Ascultă evenimente pentru actualizare stats
 * - Gestionează click-uri pe elementele de stats
 * - Aplică/curăță filtre în filterManager
 * - Protecții pentru click-uri multiple și debounce
 * - Feedback vizual pentru interacțiuni
 *
 * @example
 * // Inițializare (se face automat la import)
 * const stats = new RGYStats();
 */
class RGYStats {
  constructor() {
    // Singleton check
    if (RGYStats.instance) {
      this.log.error('⚠️ RGYStats is singleton, returning existing instance');
      return RGYStats.instance;
    }

    this.debugMode = false;

    // Aplică mixin-ul listener tracker
    ListenerTracker.applyTo(this, {
      debugMode: this.debugMode || false,
      logPrefix: 'RGYStats',
      trackPerformance: true,
    });

    this.redCount = 0;
    this.greenCount = 0;
    this.yellowCount = 0;
    this.activeStat = null;
    this.statsElemnt = null;

    // 🆕 PROTECȚIE CLICK-URI MULTIPLE
    this.isProcessingClick = false;
    this.lastClickTime = 0;
    this.clickDebounceTime = 300; // 300ms între click-uri

    // Store singleton instance
    RGYStats.instance = this;

    // 🎯 AUTO-REGISTER în registry
    registerInstance('stats', this, {
      version: '3.0.0',
      description: 'Main stats manager for dashboard',
      features: ['stats', 'event-driven', 'click-handling', 'filtering'],
      dependencies: ['filterManager', 'eventBus'],
    });
  }

  init() {
    this.statsElemnt = document.getElementById('stats-elements');

    if (!this.statsElemnt) {
      this.log.error("Nu am găsit elementul 'stats-elements!' Nu ai stats!!");
      return;
    }

    // Event listener pentru actualizare stats
    this.addBusListener(EVENTS.STATS_UPDATE, (data) => this.updateStats(data), this);
    this.addBusListener(EVENTS.STATS_REFRESH, (data) => this.updateStats(data), this);

    // Configurează click listeners pe elementele de culoare
    this.addBusListener(EVENTS.DASHBOARD_READY, () => this.setupClickListeners());

    this.addBusListener(EVENTS.DATA_REFRESH_START, () => this.showAllLoadingCircles());

    this.log('📡 STATS inițializat cu succes');
    return true;
  }

  /**
   * Configurează click listeners pe elementele de culoare
   */
  setupClickListeners() {
    const redElement = this.statsElemnt.querySelector('#red');
    const greenElement = this.statsElemnt.querySelector('#green');
    const yellowElement = this.statsElemnt.querySelector('#yellow');

    // Red click handler
    if (redElement) {
      this.addClickListener(redElement, (event) => {
        this.handleColorClick('red', this.redCount, event);
      });
    }

    // Green click handler
    if (greenElement) {
      this.addClickListener(greenElement, (event) => {
        this.handleColorClick('green', this.greenCount, event);
      });
    }

    // Yellow click handler
    if (yellowElement) {
      this.addClickListener(yellowElement, (event) => {
        this.handleColorClick('yellow', this.yellowCount, event);
      });
    }

    this.log('🖱️ Click listeners configurați pe elementele de culoare');
  }

  /**
   * Handler pentru click pe culoare - CU LOGICA TOGGLE ȘI HIDE/SHOW
   */
  async handleColorClick(color, count, event) {
    // 🛡️ PROTECȚII (păstrează toate protecțiile existente)
    if (this.isProcessingClick) {
      this.log(`⚠️ Click ignorat pe ${color} - procesez deja alt click`);
      return;
    }

    const currentTime = Date.now();
    if (currentTime - this.lastClickTime < this.clickDebounceTime) {
      this.log(`⚠️ Click prea rapid pe ${color} - așteaptă ${this.clickDebounceTime}ms`);
      return;
    }

    if (!filterManager || !filterManager.activeFilters) {
      this.log('FilterManager nu este încă inițializat, returnez');
      return;
    }

    this.isProcessingClick = true;
    this.lastClickTime = currentTime;

    // 🎯 LOGICA TOGGLE: Verifică dacă este deja activ
    if (this.activeStat === color) {
      this.log(`🔄 TOGGLE OFF: Dezactivez filtrul pentru ${color.toUpperCase()}`);

      // Curăță filtrul activ
      this.clearCurrentFilter(color);
    } else {
      // 🎯 APLICARE FILTRU NOU
      this.log(
        `🎯 TOGGLE ON: Aplicăm filtrul pentru ${color.toUpperCase()}: ${count} înregistrări`
      );

      this.applyFilter(color);
    }
  }

  applyFilter(color) {
    try {
      const startTime = performance.now();

      // Feedback vizual imediat
      this.showClickFeedback(color);

      // Construiește filtrul
      const filterData = {
        field: 'DIFF',
        operator: '=',
        value: this.getColorValue(color),
        type: 'exact',
        id: `stat-${color}`,
        filterString: `DIFF = ${this.getColorValue(color)}`,
        otherFilters: this.buildOtherFilters(`stat-${color}`),
      };

      const emitOptions = {
        currentFilter: `DIFF=${this.getColorValue(color)}`,
        hideHidden: 0,
        otherFilters: filterData.otherFilters,
        value: this.getColorValue(color),
        reason: 'filter_applied_stats',
        sort: '',
        timestamp: Date.now(),
        view: getInstance('tabs').currentView,
      };

      // Il ascultă data-loader/handleRefreshRequest, table-builder/showTableLoading
      eventBus.emit(EVENTS.DATA_REFRESH_START, emitOptions);

      // Așteaptă răspunsul
      this.waitForEventResult(
        EVENTS.DATA_REFRESH_COMPLETE,
        (error, result) => {
          if (error) {
            this.log('⚠️ Timeout sau eroare la așteptarea refreshului:', error.message);
            return;
          } else {
            this.log('🔄 Refresh completat după aplicarea filtrului:', result);
          }
        },
        3000
      );

      // Setează filtrul în manager
      filterManager.activeFilters.set(filterData.id, filterData);

      // 🎯 SETEAZĂ CA ACTIV ȘI ASCUNDE CELELALTE
      this.setActiveStat(color);
      this.hideOtherButtons(color);
      this.isProcessingClick = false;

      const filterTime = performance.now() - startTime;

      this.log(`✅ Click processat cu succes în ${filterTime.toFixed(2)}ms`);
    } catch (error) {
      this.log.error('Eroare la aplicarea filtrului', error);

      eventBus.emit(EVENTS.FILTER_ERROR, {
        action: 'filter_apply_stats',
        error: error.message,
        filterData: null,
        timestamp: Date.now(),
      });
    } finally {
      this.isProcessingClick = false;
      this.hideClickFeedback(color);
    }
  }

  /**
   * 🆕 CURĂȚĂ FILTRUL ACTIV
   */
  clearCurrentFilter(color) {
    try {
      this.log(`🗑️ Ștergere filtru pentru: ${color}`);

      const emitOptions = {
        currentFilter: '',
        hideHidden: 0,
        otherFilters: this.buildOtherFilters(`stat-${color}`),
        value: '',
        reason: 'filter_cleared_stats',
        sort: '',
        timestamp: Date.now(),
        view: getInstance('tabs').currentView,
      };

      // Emit eveniment pentru refresh tabel
      // Il asculta data-loader/handleRefreshRequest
      eventBus.emit(EVENTS.DATA_REFRESH_START, emitOptions);

      // Așteaptă răspunsul
      this.waitForEventResult(
        EVENTS.DATA_REFRESH_COMPLETE,
        (error, result) => {
          if (error) {
            this.log('⚠️ Timeout sau eroare la așteptarea refreshului:', error.message);
          } else {
            this.log('🔄 Refresh completat după aplicarea filtrului:', result);
          }
        },
        3000
      );

      filterManager.activeFilters.delete(`stat-${color}`);

      // Afișează toate butoanele
      this.showAllButtons();

      // Resetează activeStat
      this.activeStat = null;
      this.isProcessingClick = false;

      this.log(`✅ Filtru curățat și toate butoanele afișate`);
    } catch (error) {
      this.log.error('Eroare la ștergerea filtrului', error);
    }
  }

  /**
   * Construiește other filters (exact ca în filter-manager)
   */
  buildOtherFilters(currentFilterId) {
    const activeFilters = getInstance('filterManager').activeFilters;
    return activeFilters instanceof Map
      ? Array.from(activeFilters.values())
          .filter((v) => v && v.filterString && v.id !== currentFilterId)
          .map((v) => v.filterString)
          .join(' AND ')
      : '';
  }

  /**
   * 🆕 ASCUNDE CELELALTE BUTOANE (păstrează doar cel activ vizibil)
   */
  hideOtherButtons(activeColor) {
    const colors = ['red', 'green', 'yellow'];

    colors.forEach((color) => {
      const element = this.statsElemnt.querySelector(`#${color}`);
      if (!element) return;

      if (color === activeColor) {
        // Butonul activ rămâne vizibil și marcat
        element.style.display = '';
        element.classList.add('stat-active');
        element.classList.add('stat-clicked');
        this.log(`✅ ${color.toUpperCase()} rămâne vizibil (activ)`);
      } else {
        // Celelalte butoane se ascund
        element.style.display = 'none';
        element.classList.remove('stat-active');
        element.classList.remove('stat-clicked');
        this.log(`🙈 ${color.toUpperCase()} ascuns`);
      }
    });
  }

  /**
   * 🆕 AFIȘEAZĂ TOATE BUTOANELE
   */
  showAllButtons() {
    const colors = ['red', 'green', 'yellow'];

    colors.forEach((color) => {
      const element = this.statsElemnt.querySelector(`#${color}`);
      if (!element) return;

      // Afișează butonul și resetează starea
      element.style.display = '';
      element.classList.remove('stat-active');
      element.classList.remove('stat-clicked');
      element.classList.remove('stat-processing');

      this.log(`👁️ ${color.toUpperCase()} afișat`);
    });
  }

  /**
   * MODIFICĂ setActiveStat să nu mai facă updateVisualFeedback automat
   */
  setActiveStat(color) {
    // Doar setează starea, fără visual feedback (se face în hideOtherButtons)
    this.activeStat = color;
    this.log(`📌 Statistică activă: ${color}`);
  }

  /**
   * Actualizează feedback visual
   */
  updateVisualFeedback(activeColor) {
    const colors = ['red', 'green', 'yellow'];

    colors.forEach((color) => {
      const element = this.statsElemnt.querySelector(`#stat-${color}`);
      if (!element) return;

      if (color === activeColor) {
        // Marchează ca activ
        element.classList.add('stat-active');
        element.classList.add('stat-clicked');
      } else {
        // Resetează celelalte
        element.classList.remove('stat-active');
        element.classList.remove('stat-clicked');
      }
    });
  }

  /**
   * Curăță visual activ
   */
  clearActiveVisual(color) {
    const element = this.statsElemnt.querySelector(`#stat-${color}`);
    if (element) {
      element.classList.remove('stat-active');
      element.classList.remove('stat-clicked');
    }
  }

  // 🆕 FUNCȚIE NOUĂ: Feedback vizual pentru click
  showClickFeedback(color) {
    const element = this.statsElemnt.querySelector(`#stat-${color}`);
    if (element) {
      // Adaugă clasă CSS pentru loading state
      element.classList.add('stat-processing');
      element.style.opacity = '0.7';
      element.style.cursor = 'wait';

      // Opțional: adaugă un mic spinner sau text
      const originalText = element.textContent;
      element.setAttribute('data-original-text', originalText);
      element.textContent = '⏳ ' + originalText;
    }
  }

  // 🆕 FUNCȚIE NOUĂ: Curăță feedback vizual
  hideClickFeedback(color) {
    const element = this.statsElemnt.querySelector(`#stat-${color}`);
    if (element) {
      element.classList.remove('stat-processing');
      element.style.opacity = '';
      element.style.cursor = '';

      // Restaurează textul original
      const originalText = element.getAttribute('data-original-text');
      if (originalText) {
        element.textContent = originalText;
        element.removeAttribute('data-original-text');
      }
    }
  }

  /**
   * Actualizare stats (cod original păstrat)
   */
  updateStats(statsData) {
    // Extrage datele din obiectul primit
    if (!statsData.data) return;
    this.hideAllLoadingCircles();

    const data = statsData.data;

    // Actualizează contoarele interne
    this.redCount = data.red || 0;
    this.greenCount = data.green || 0;
    this.yellowCount = data.yellow || 0;

    // Actualizează elementele HTML
    this.updateHTMLElements();
  }

  /**
   * Actualizează elementele HTML
   */
  updateHTMLElements() {
    if (!this.statsElemnt) {
      this.log.error('Element stats nu există!');
      return;
    }

    // Găsește și actualizează fiecare element
    const redElement = this.statsElemnt.querySelector('#stat-red');
    const greenElement = this.statsElemnt.querySelector('#stat-green');
    const yellowElement = this.statsElemnt.querySelector('#stat-yellow');

    // Actualizează textul
    if (redElement) {
      redElement.textContent = this.redCount;
    }

    if (greenElement) {
      greenElement.textContent = this.greenCount;
    }

    if (yellowElement) {
      yellowElement.textContent = this.yellowCount;
    }

    this.log(
      `📊 Stats actualizate: R:${this.redCount}, G:${this.greenCount}, Y:${this.yellowCount}`
    );
  }

  /**
   * 🎯 MAPARE CULOARE
   */
  getColorValue(color) {
    const colorValueMap = {
      red: 3,
      green: 1,
      yellow: 2,
    };

    return colorValueMap[color] || 0; // fallback la 0 dacă culoarea nu există
  }

  /**
   * 🆕 FUNCȚIE GENERALĂ: Afișează cercuri de loading pentru toate statisticile
   */
  showAllLoadingCircles() {
    const colors = ['red', 'green', 'yellow'];

    colors.forEach((color) => {
      const element = this.statsElemnt.querySelector(`#stat-${color}`);
      if (element) {
        // Salvează conținutul original complet
        const originalHTML = element.innerHTML;
        element.setAttribute('data-original-html', originalHTML);

        // Creează un cerc de loading animat
        const loadingCircle = `
        <div class="loading-circle-container" style="
          display: inline-flex; 
          align-items: center; 
          justify-content: center;
          width: 100%;
          height: 100%;
        ">
          <div class="loading-circle" style="
            width: 16px;
            height: 16px;
            border: 3px solid rgba(0, 0, 104, 1);
            border-top: 3px solid #ffffff;
            border-radius: 50%;
            animation: spin-circle 1s linear infinite;
          "></div>
        </div>
      `;

        // Înlocuiește conținutul cu cercul de loading
        element.innerHTML = loadingCircle;
        element.classList.add('stat-loading');
        element.style.cursor = 'wait';
      }
    });

    // Adaugă animația CSS dacă nu există deja
    if (!document.getElementById('loading-circle-styles')) {
      const style = document.createElement('style');
      style.id = 'loading-circle-styles';
      style.textContent = `
      @keyframes spin-circle {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
      }
      .stat-loading {
        opacity: 0.8;
        pointer-events: none;
      }
    `;
      document.head.appendChild(style);
    }

    this.log('🔄 Cercuri de loading afișate pentru toate statisticile');
  }

  /**
   * 🆕 FUNCȚIE GENERALĂ: Șterge toate cercurile de loading și restaurează conținutul original
   */
  hideAllLoadingCircles() {
    const colors = ['red', 'green', 'yellow'];

    colors.forEach((color) => {
      const element = this.statsElemnt.querySelector(`#stat-${color}`);
      if (element) {
        // Restaurează conținutul original complet
        const originalHTML = element.getAttribute('data-original-html');
        if (originalHTML) {
          element.innerHTML = originalHTML;
          element.removeAttribute('data-original-html');
        }

        // Curăță clasele și stilurile
        element.classList.remove('stat-loading');
        element.style.cursor = '';
        element.style.opacity = '';
      }
    });

    this.log('✅ Toate cercurile de loading șterse și conținut restaurat');
  }

  // Funcție helper generică care așteaptă orice eveniment cu callback
  waitForEventResult(eventName, callback, timeout = 10000) {
    // 🎯 FOLOSEȘTE ONCE în loc de listener normal
    const cleanup = this.addBusListenerOnce(eventName, (result) => {
      clearTimeout(timeoutId);
      callback(null, result); // Success callback
    });

    // Timeout simplu
    const timeoutId = setTimeout(() => {
      cleanup(); // Curăță listener-ul once
      callback(new Error('Timeout'), null); // Error callback
    }, timeout);
  }

  /**
   * Cleanup la distrugere
   */
  destroy() {
    this.activeStat = null;
    this.statsElemnt = null;

    // 🎯 RESET SINGLETON
    RGYStats.instance = null;

    // ListenerTracker se ocupă automat de cleanup-ul event listeners
    this.log('🧹 RGYStats distrus și curățat');
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
        const CPN = 'RGYStats'.padEnd(15);
        console.log(
          `%c[${ts}] [${CPN}] ${message}`,
          'color: #ccb6feff; font-weight: bold;',
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
      const CPN = 'RGYStats'.padEnd(15);
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
const stats = new RGYStats();

// Export pentru module
export default stats;

// Global access pentru compatibilitate
// statsController = stats;
