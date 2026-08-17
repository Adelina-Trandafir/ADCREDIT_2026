/**
 * 🎨 FILTER UI MIXIN
 * Gestionează modal lifecycle, visuals și accordion
 *
 * RESPONSABILITĂȚI:
 * ✅ Modal open/close/animations
 * ✅ Normal (inline) mode
 * ✅ Visual updates (filter icons)
 * ✅ Accordion behavior
 * ✅ Position management
 *
 * @version 4.0.0
 */

export const filterUIMixin = {
  /**
   * 📂 AFIȘARE MODAL (standard floating mode)
   */
  async showModal(data, source = 'table') {
    // Nu deschide modal floating când filter-panel (panel-dreapta) e vizibil
    const panelDreapta = document.getElementById('panel-dreapta');
    if (panelDreapta && !panelDreapta.classList.contains('hidden')) return;

    // Restaurează referințele la modalul din body dacă showNormal le-a suprascris
    const bodyModal = document.getElementById('filterWindow');
    if (bodyModal && this.modalElement !== bodyModal) {
      this.elementId = 'filterWindow';
      this.initializeModalComponents();
    }

    this.currentSource = source;
    let defaultType = '';
    // Daca se muta de la un header la altul, curata clasa pe headerul vechi
    if (this.headerElement && this.headerElement !== data.data.headerElement) {
      this.headerElement.classList.remove('filter-header-active');
    }

    this.headerElement = data.data.headerElement;

    try {
      if (this.currentColumn !== data.data.column) {
        if (this.currentColumn) this.resetForm();

        // Setează variabilele de stare (din filter-form.js)
        this.setCurrentColumn(data.data.column);

        this.log('📋 Afișare modal pentru coloană', this.currentField);

        // Controlează vizibilitatea secțiunilor
        this.toggleExactFilterVisibility();
        this.togglePartialFilterVisibility();
        this.toggleRangeFilterVisibility();

        // Accordion inițial
        defaultType = this.initializeAccordionBasedOnType();

        if (defaultType === 'range' && this.currentColumn.type === 'date') {
          await this.initializeCalendarWidgets();
        }
      } else {
        // Accordion inițial
        defaultType = this.initializeAccordionBasedOnType();
      }
      // Dimensionează modal-ul la lățimea coloanei
      // Poziționare sub header
      this.positionModalUnderHeader();

      // Populează cu datele curente
      await this.populateModalData(defaultType);

      // Animație afișare
      this.showModalWithAnimation();

      // Focus pe input-ul potrivit
      setTimeout(() => {
        this.focusAppropriateInputForType(defaultType);
      }, 100);

      // Update metrics
      this.updateMetrics('modal_opened');

      this.isVisible = true;
      this.isModal = true;
    } catch (error) {
      this.handleError('Eroare la afișarea modalului', error);
    }
  },

  /**
   * ❌ ÎNCHIDERE MODAL
   */
  hideModal() {
    if (this.modalElement) {
      this.hideModalWithAnimation(this.modalElement);
    }

    this.isVisible = false;
    this.isModal = false;
  },

  /**
   * 📂 AFIȘARE NORMAL (inline în sub-panel)
   */
  async showNormal(Data, source = 'filter-panel') {
    this.currentSource = source;
    this.className = '.filter-window-content';

    const { columnData, subPanel } = Data.data;
    this.elementId = `filterPanelSubpanel${columnData.id}`;

    try {
      if (!subPanel) {
        this.handleError(`Container subPanel-${columnData.id} nu a fost găsit`);
        return;
      }

      // Setup data
      this.setCurrentColumn(columnData);

      this.updateFilterOptionsAvailability(columnData.type);

      // Injectează în container fix
      await this.injectFilterContentIntoContainer(subPanel);

      // Restul logic reutilizat din showModal
      this.resetForm();
      const defaultType = this.initializeAccordionBasedOnType();

      // Setup events pe noul container imediat după injectare HTML,
      // înainte de operațiile async (fetch combobox/calendar), astfel
      // încât click-urile rapide pe acordeon sunt capturate corect
      this.setupModalEventListeners(subPanel);

      if (defaultType === 'range' && columnData.type === 'date') {
        await this.initializeCalendarWidgets();
      }

      this.destroyExistingCombobox();
      await this.initializeExactCombobox();

      // Populează cu datele curente
      await this.populateModalData(defaultType);

      this.isVisible = true;
      this.isModal = false;

      this.log('✅ Filter normal afișat în sub-panel');
    } catch (error) {
      this.handleError('Eroare la afișarea filter normal', error);
    }
  },

  /**
   * ❌ ASCUNDE NORMAL
   */
  hideNormal(fieldName) {
    const targetContainer = document.getElementById(`subPanel-${fieldName}`);
    if (!targetContainer) return;

    this.destroyExistingCombobox();
    targetContainer.innerHTML =
      '<div class="filter-panel-subpanel-loading">Se încarcă opțiunile de filtrare...</div>';

    if (this.currentField === fieldName) {
      this.currentColumn = null;
    }
    this.isVisible = false;
    this.isModal = false;

    this.log(`❌ Filter normal ascuns pentru: ${fieldName}`);
  },

  /**
   * 📍 POZIȚIONARE MODAL
   */
  positionModalUnderHeader() {
    if (!this.headerElement) return;
    const headerRect = this.headerElement.getBoundingClientRect();
    const headerWidth = Math.max(headerRect.width, 280);

    // Calculează poziția pentru a fi sub header
    let leftPosition = Number(headerRect.left + window.scrollX);

    // Ajustează dacă modal-ul ar ieși din viewport
    const viewportWidth = window.innerWidth;
    const rightEdge = leftPosition + headerWidth;

    if (rightEdge > viewportWidth - 20) {
      leftPosition = headerRect.right + window.scrollX - headerWidth;
    }

    // Asigură-te că nu iese pe stânga
    leftPosition = Math.max(leftPosition, 10);

    // Poziționare sub header
    this.modalElement.style.position = 'absolute';
    this.modalElement.style.top = `${headerRect.bottom + window.scrollY - 1}px`;
    this.modalElement.style.left = `${leftPosition}px`;
    this.modalElement.style.width = `${headerWidth}px`;
    //this.modalElement.style.zIndex = Math.floor(window.ZIndexManager.getNext());
  },

  /**
   * 🎬 ANIMAȚII
   */
  showModalWithAnimation() {
    this.modalElement.style.display = 'block';

    // Adaugă clasa inițială
    this.modalElement.classList.add('drop-in-start');
    this.modalElement.classList.remove('hidden');

    // IMPORTANT: Dublu requestAnimationFrame pentru timing corect!
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        // Acum browser-ul a procesat display: block și drop-in-start
        this.modalElement.classList.remove('drop-in-start');
        this.modalElement.classList.add('drop-in-end');
      });

      // Subscribe DUPĂ ce animația a început
      window.overlay.subscribe(this, this.modalElement, {
        onClick: () => this.hideModal(),
        onEscape: () => this.hideModal(),
        parent: document.getElementById('tableBodyScroll'),
      });
    });

    this.headerElement?.classList.add('filter-header-active');
  },

  hideModalWithAnimation() {
    // 1. Aplică animația de închidere
    this.modalElement.classList.remove('drop-in-end');
    this.modalElement.classList.add('drop-out');

    // 2. Așteaptă să se termine animația (250ms conform CSS-ului tău)
    setTimeout(() => {
      // 3. Acum ascunde modalul complet
      this.modalElement.classList.remove('drop-out');
      this.modalElement.classList.add('hidden');

      // 5. ACUM face unsubscribe (la final!)
    }, 250); // Sync cu transition: 0.25s din .drop-out
    window.overlay.unsubscribe(this);
    this.headerElement?.classList.remove('filter-header-active');
  },
};
