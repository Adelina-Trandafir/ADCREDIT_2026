export const PanelUIMixin = {
  showModalOverlay() {
    if (!this.modalOverlay) return;

    this.modalOverlay.style.display = 'block';

    // Animație fade-in
    this.modalOverlay.style.opacity = '0';
    setTimeout(() => {
      this.modalOverlay.style.opacity = '1';
    }, 10);

    this.log('👁️ Modal overlay afișat');
  },

  hideModalOverlay() {
    if (!this.modalOverlay) return;
    this.modalOverlay.style.opacity = '0';
    setTimeout(() => {
      this.modalOverlay.style.display = 'none';
    }, 300);

    this.log('🙈 Modal overlay ascuns');
  },

  openModal() {
    if (!this.panelElement || this.isVisible) return;
    this.setupDOMListeners();

    this.log('🎭 Afișez panelul cu animație');

    //this.overlayElement.classList.add('visible');
    //this.overlayElement.classList.remove('hidden');

    //this.panelElement.style.zIndex = Number(window.ZIndexManager.getNext()) + 5000;
    this.panelElement.classList.remove('hidden');
    this.panelElement.classList.add('zoom-in-start');

    // Trigger animation
    setTimeout(() => {
      window.overlay.subscribe(this, this.panelElement, {
        onClick: () => this.closeModal(),
        onEscape: () => this.closeModal(),
        parent: document.getElementById('tableBodyScroll'),
      });
      this.panelElement.classList.remove('zoom-in-start');
      this.panelElement.classList.add('zoom-in-end');
    }, 10);

    // this.overlayElement.style.zIndex = Number(window.ZIndexManager.getNext()) + 4999;

    this.isVisible = true;
  },

  closeModal() {
    if (!this.panelElement || !this.isVisible) return;
    this.clearDOMListeners();

    // Animație zoom-out
    this.panelElement.classList.remove('zoom-in-end');
    this.panelElement.classList.add('zoom-out');

    // Ascunde overlay
    //this.overlayElement.classList.remove('visible');
    //this.overlayElement.classList.add('hidden');

    // După animație, ascunde complet
    setTimeout(() => {
      this.panelElement.classList.add('hidden');
      this.panelElement.classList.remove('zoom-out');
      window.overlay.unsubscribe(this);

      // Reset z-index
      // this.overlayElement.style.zIndex = 0;
      // this.panelElement.style.zIndex = 0;
    }, 100);

    this.isVisible = false;
  },

  async openModalFeedback() {
    if (!this.currentRowId) {
      console.warn('Cannot open feedback: no active row');
      return;
    }

    if (!this.feedbackModal) {
      console.error('FeedbackModal instance not found');
      return;
    }

    // Get middle container element
    const middleContainer = document.getElementById('detailsPanelBazaMiddle');
    if (!middleContainer) {
      console.error('Middle container not found');
      return;
    }

    // ✅ Deschide inline în container
    await this.feedbackModal.openInlineModal(this.currentRowId, middleContainer);
  },

  // ============================================================================
  // 🛠️ GESTIONAREA PANELULUI
  // ============================================================================
  /**
   * Deschide panelul pentru un rând specific
   * @param {HTMLElement} rowElement - Elementul rând
   * @param {string} rowId - ID-ul rândului
   * @param {number} rowIndex - Indexul rândului
   */
  async openPanel(rowElement, rowId, rowIndex) {
    if (this.isVisible) {
      this.log('⚠️ Panelul este deja deschis');
      return;
    }

    this.log(`📂 Deschid panelul pentru rândul ${rowId}`);

    try {
      this.currentRowElement = rowElement;
      this.currentRowId = rowId;

      this.currentRowData = await this.getInstance('dataLoader').allData(rowId, 'IdBaza');
      this.originalData = { ...this.currentRowData };

      this.populateForm(this.currentRowData);
      await this.loadFeedback(rowId);

      this.sendMailBtnElement.disabled = this.components.formInputs.get('aMail') == '';

      if (this.currentRowData[0].IDSG === 1) {
        this.disableAllControls();
        this.saveButton.disabled = true;
        this.addFeedbackBtnElement.disabled = true;
      } else {
        this.enableAllControls();
        this.saveButton.disabled = false;
        this.addFeedbackBtnElement.disabled = false;
      }
      this.openModal();
      this.isVisible = true;
      this.stats.opens++;

      this.log(
        `✅ Panel${this.disableTable ? ' MODAL' : ''}${this.openAsPageFooter ? ' BOTTOM' : ''} deschis cu succes`
      );

      this.eventBus.emit(this.EVENTS.DETAILS_PANEL_OPENED, {
        rowId,
        isModal: this.disableTable,
        isBottomPanel: this.openAsPageFooter,
        timestamp: Date.now(),
      });
    } catch (error) {
      this.log.error('Eroare la deschiderea panelului', error);
    }
  },
};
