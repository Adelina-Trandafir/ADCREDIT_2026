export const filterModalWindow = {
  /**
   * 🚀 INIȚIALIZARE UI
   */
  async initializeUI() {
    this.log('🎨 Inițializare element DOM pentru filtru...');

    // Încarcă template-ul modal
    await this.ensureModalExists();

    this.log('✅ Filter UI inițializat');
  },

  /**
   * 🔧 HELPERS - Modal DOM
   */
  async ensureModalExists() {
    if (this.injectedFilterDIV) return Promise.resolve();

    return fetch('/static/html/filter_modal.html')
      .then((r) => r.text())
      .then((html) => {
        document.body.insertAdjacentHTML('beforeend', html);
        this.injectedFilterDIV = true;

        return new Promise((resolve) => {
          requestAnimationFrame(() => {
            this.initializeModalComponents();
            resolve();
          });
        });
      })
      .catch((error) => {
        this.log('HTML extern nu s-a încărcat, folosind HTML injectat', error);
        this.injectModalHTML();
        return Promise.resolve();
      });
  },

  initializeModalComponents() {
    const modalId = this.elementId || 'filterWindow';
    const modal = document.getElementById(modalId);
    if (!modal) {
      this.log.error(`Modal ${modalId} nu a fost găsit`);
      return;
    }

    this.modalElement = modal;
    this.applyBtnElement = modal.querySelector('#applyFilterBtn');
    this.clearBtnElement = modal.querySelector('#clearFilterBtn');
    this.comboboxElement = modal.querySelector('#exactFilterContainer');

    this.exactFilterContainer = modal.querySelector('#exactFilter');
    this.partialFilterContainer = modal.querySelector('#partialFilter');
    this.rangeFilterContainer = modal.querySelector('#rangeFilter');
    this.optionElements = {
      exact: this.exactFilterContainer,
      partial: this.partialFilterContainer,
      range: this.rangeFilterContainer,
    };

    this.partialTextElement = modal.querySelector('#partialFilterText');
    this.rangeFromElement = modal.querySelector('#rangeFrom');
    this.rangeToElement = modal.querySelector('#rangeTo');

    this.modalElement.querySelectorAll('input[name="filterType"]').forEach((radio) => {
      // Salvează butoanele de opțiuni pentru uz ulterior
      this.optionButtons[radio.value] = radio;
    });
  },

  injectModalHTML() {
    const errorHTML = `
      <div id="filterWindow" class="filter-window">
        <div id="filterWindowContent" class="filter-window-content" style="max-width: 400px; text-align: center;">
          <div id="filterWindowBody" class="filter-window-body">
            <p style="color: #dc2626; margin: 20px 0;">Nu s-a putut încărca interfața de filtrare.</p>
          </div>
        </div>
      </div>
    `;

    document.body.insertAdjacentHTML('beforeend', errorHTML);
    this.injectedFilterDIV = true;
  },

  /**
   * 🎯 Afișare in panel
   */
  async injectFilterContentIntoContainer(targetContainer) {
    try {
      const response = await fetch('/static/html/filter_modal.html');
      const html = await response.text();

      targetContainer.innerHTML = html;

      // Fă vizibil #filterWindow (are display:none în CSS implicit)
      const filterWindow = targetContainer.querySelector('#filterWindow');
      if (filterWindow) {
        filterWindow.style.display = 'block';
        filterWindow.style.opacity = '1';
        filterWindow.style.position = 'static';
        // Elimină clasa hidden de pe secțiunile de filtru
        filterWindow.querySelectorAll('.filter-window-options').forEach((el) => {
          el.classList.remove('hidden');
        });
      }

      // Re-inițializează toate referințele la elementele din acest container
      this.modalElement = filterWindow || targetContainer;
      this.applyBtnElement = targetContainer.querySelector('#applyFilterBtn');
      this.clearBtnElement = targetContainer.querySelector('#clearFilterBtn');
      this.comboboxElement = targetContainer.querySelector('#exactFilterContainer');
      this.exactFilterContainer = targetContainer.querySelector('#exactFilter');
      this.partialFilterContainer = targetContainer.querySelector('#partialFilter');
      this.rangeFilterContainer = targetContainer.querySelector('#rangeFilter');
      this.partialTextElement = targetContainer.querySelector('#partialFilterText');
      this.rangeFromElement = targetContainer.querySelector('#rangeFrom');
      this.rangeToElement = targetContainer.querySelector('#rangeTo');
      this.optionButtons = {};
      targetContainer.querySelectorAll('input[name="filterType"]').forEach((radio) => {
        this.optionButtons[radio.value] = radio;
      });

      // Resetează flag-ul pentru event listeners (vor fi re-atașate pe noul container)
      this.areModalEventListenersSet = false;

      this.log('✅ HTML complet încărcat în container');
    } catch (error) {
      this.log.error('⚠️ HTML extern nu s-a încărcat', error);
      return;
    }
  },

  clearHighlightColumnRow() {
    if (!this.isVisible || !this.columnsList) return;

    const allItems = this.columnsList.querySelectorAll('.panel-right-filter-column-item');
    allItems.forEach((item) => {
      item.classList.remove('simulated-hover');
    });
  },

  /**
   * 🎯 HIGHLIGHT RÂND COLOANĂ
   */
  highlightColumnRow(columnId) {
    const columnRow = this.columnsList.querySelector(
      `[data-field="${columnId}"].panel-right-filter-column-item`
    );
    if (columnRow) {
      columnRow.classList.add('simulated-hover');
      columnRow.scrollIntoView({
        behavior: 'smooth',
        block: 'nearest',
      });
    }
  },

  showSubPanel(columnElement, fieldName, displayName) {
    const subPanel = this.createSubPanel(fieldName);
    columnElement.parentNode.insertBefore(subPanel, columnElement.nextSibling);

    this.subPanelState = {
      activeElement: columnElement,
      currentSubPanel: subPanel,
      isVisible: true,
      currentFieldName: fieldName,
      currentDisplayName: displayName,
    };

    columnElement.classList.add('expanded');
    this.log(`📂 Sub-panel afișat pentru: ${displayName}`);

    return subPanel;
  },

  hideSubPanel() {
    if (!this.subPanelState.isVisible || !this.subPanelState.currentSubPanel) {
      return;
    }

    if (this.subPanelState.activeElement) {
      this.subPanelState.activeElement.classList.remove('expanded');
    }

    this.subPanelState.currentSubPanel.remove();

    this.subPanelState = {
      activeElement: null,
      currentSubPanel: null,
      isVisible: false,
      currentFieldName: '',
      currentDisplayName: '',
    };

    this.log('❌ Sub-panel ascuns');
  },

  createSubPanel(fieldName) {
    const subPanel = document.createElement('div');
    subPanel.id = `filterPanelSubpanel${fieldName}`;
    subPanel.className = 'filter-panel-subpanel';
    subPanel.innerHTML = `
      <div id="filterPanelSubpanelContent${fieldName}" class="filter-panel-subpanel-content">
        <div id="filterPanelSubpanelLoading" class="filter-panel-subpanel-loading">Se încarcă opțiunile de filtrare...</div>
      </div>
    `;
    return subPanel;
  },

  /**
   * ⚠️ AFIȘARE EROARE
   */
  showError(message) {
    let errorElement = document.querySelector('.modal-error');

    if (!errorElement) {
      errorElement = document.createElement('div');
      errorElement.className = 'modal-error';
      errorElement.style.cssText = `
        background: #fee;
        border: 1px solid #fcc;
        color: #c33;
        padding: 10px;
        margin: 10px 0;
        border-radius: 4px;
        font-size: 14px;
      `;

      const modalBody = document.querySelector('.filter-window-options, .filter-modal-body');
      if (modalBody) {
        modalBody.insertBefore(errorElement, modalBody.firstChild);
      }
    }

    errorElement.textContent = message;
    errorElement.style.display = 'block';

    setTimeout(() => {
      if (errorElement) {
        errorElement.style.display = 'none';
      }
    }, 5000);
  },
};
