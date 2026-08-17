// js/components/dashboard/details-panel/details-panel-loader-this.js
/**
 * ========== DETAILS PANEL LOADER MANAGER - Modul pentru încărcare și loading states ==========
 * Gestionează încărcarea template-urilor, stilurilor și stările de loading
 *
 * @version 2.0.0 - Extras din details-panel-this.js
 */

export const PanelLoaderMixin = {
  /**
   * Încarcă stilurile pentru panel
   */
  async loadPanelStyles() {
    if (document.getElementById('detailsPanelBazaBazaStyles')) {
      this.log('✅ Stilurile sunt deja încărcate');
      return;
    }

    this.log('🎨 Încarc stilurile pentru panel...');

    try {
      const linkdetailsPanelBaza = document.createElement('link');
      linkdetailsPanelBaza.id = 'detailsPanelBazaBazaStyles';
      linkdetailsPanelBaza.rel = 'stylesheet';
      linkdetailsPanelBaza.href = '/static/css/details_panel_baza.css';
      document.head.appendChild(linkdetailsPanelBaza);

      // if (!document.querySelector('link[href*="treeview.css"]')) {
      //   const linkTreeview = document.createElement('link');
      //   linkTreeview.rel = 'stylesheet';
      //   linkTreeview.href = '/static/css/treeview.css';
      //   document.head.appendChild(linkTreeview);
      // }

      await new Promise((resolve) => {
        linkdetailsPanelBaza.onload = resolve;
        linkdetailsPanelBaza.onerror = () => {
          this.log.error('Eroare la încărcarea stilurilor');
          resolve();
        };
      });

      this.log('✅ Stiluri încărcate cu succes');
    } catch (error) {
      this.log.error('Eroare la încărcarea stilurilor', error);
    }
  },

  /**
   * Încarcă template-ul HTML pentru panel
   * @returns {Promise<string>} Template-ul HTML
   */
  async loadPanelTemplate() {
    try {
      const response = await fetch('/static/html/details_panel_baza.html?v=' + Date.now());

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const template = await response.text();
      this.log('✅ Template HTML încărcat cu succes');
      return template;
    } catch (error) {
      this.log.error('Eroare la încărcarea template-ului!', error);
      return '<div class="error">Eroare la încărcarea template-ului</div>';
    }
  },

  /**
   * Setează starea de loading pentru un element
   * @param {string} elementId - ID-ul elementului
   * @param {boolean} isLoading - Starea de loading
   * @param {string} requestType - Tipul cererii
   */
  setElementLoadingState(elementId, isLoading, requestType = null) {
    const container = this.panelElement?.querySelector(`#g_${elementId}`);
    if (!container) {
      this.log.error(`❌ Element lipsă: ${elementId}`);
      return;
    }

    if (isLoading) {
      container.setAttribute('data-loading-type', requestType || 'unknown');
      container.setAttribute('data-loading', 'true');
      container.classList.add('loading-state');

      if (container.classList.contains('form-control-combo')) {
        const input = container.querySelector('.combobox-input, .treeview-input');
        if (input) {
          input.disabled = true;
          input.placeholder = 'Se încarcă...';
        }
        addLoadingSpinner(container);
      }

      this.log(`🔄 Loading activat pentru ${elementId} (${requestType})`);
    } else {
      container.removeAttribute('data-loading-type');
      container.removeAttribute('data-loading');
      container.classList.remove('loading-state');

      if (container.classList.contains('form-control-combo')) {
        const input = container.querySelector('.combobox-input, .treeview-input');
        if (input) {
          input.disabled = false;

          if (elementId === 'JudetClient') {
            input.placeholder = 'Selectați județul...';
          } else if (elementId === 'SursaAgent') {
            input.placeholder = 'Selectați sursa...';
          } else if (elementId === 'NumeConsultant') {
            input.placeholder = 'Selectați consultantul...';
          }
        }
        removeLoadingSpinner(container);
      }

      this.log(`✅ Loading dezactivat pentru ${elementId}`);
    }
  },

  /**
   * Curăță stările de loading pentru un tip de cerere
   * @param {string} requestType - Tipul cererii
   */
  clearLoadingStateByType(requestType) {
    const containers = this.panelElement?.querySelectorAll(`[data-loading-type="${requestType}"]`);
    containers?.forEach((container) => {
      const elementId = container.id;
      this.setElementLoadingState(elementId, false);
    });
  },

  /**
   * Adaugă spinner de loading
   * @param {HTMLElement} container - Container-ul pentru spinner
   */
  addLoadingSpinner(container) {
    if (container.querySelector('.form-loading-spinner')) {
      return;
    }

    const spinner = document.createElement('div');
    spinner.className = 'form-loading-spinner';
    spinner.innerHTML = `<div class="spinner-circle"></div>`;

    container.appendChild(spinner);
    ensureLoadingStyles();
  },

  /**
   * Elimină spinner-ul de loading
   * @param {HTMLElement} container - Container-ul cu spinner
   */
  removeLoadingSpinner(container) {
    const spinner = container.querySelector('.form-loading-spinner');
    if (spinner) {
      spinner.remove();
    }
  },

  /**
   * Asigură că stilurile pentru loading sunt încărcate
   */
  ensureLoadingStyles() {
    if (document.getElementById('detailsPanelBazaLoadingStyles')) {
      return;
    }

    const style = document.createElement('style');
    style.id = 'detailsPanelBazaLoadingStyles';
    style.textContent = `
    .form-control-combo.loading-state {
      position: relative;
      opacity: 0.7;
      pointer-events: none;
    }
    
    .form-loading-spinner {
      position: absolute;
      right: 8px;
      top: 50%;
      transform: translateY(-50%);
      z-index: 10;
      pointer-events: none;
    }
    
    .spinner-circle {
      width: 16px;
      height: 16px;
      border: 2px solid #f3f3f3;
      border-top: 2px solid #667eea;
      border-radius: 50%;
      animation: details-panel-spin 0.8s linear infinite;
    }
    
    @keyframes details-panel-spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    
    .loading-state .combobox-input:disabled,
    .loading-state .treeview-input:disabled {
      background-color: #f8f9fa;
      color: #6c757d;
      cursor: wait;
    }
    
    .loading-state .combobox-arrow,
    .loading-state .treeview-arrow {
      display: none;
    }
  `;

    document.head.appendChild(style);
  },
};
