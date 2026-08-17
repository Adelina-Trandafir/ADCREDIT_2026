export const feedbackUIMixin = {
  /**
   * Deschide modal inline în container specific
   */
  async openInlineModal(rowId, containerElement) {
    this.log('📂 Deschid modal inline pentru rowId:', rowId);

    // Salvează configurația embedded
    this.isEmbeddedMode = true;
    this.embeddedContainer = containerElement;
    this.originalParent = this.modalElement?.parentElement || document.body;

    // ✅ CRITICAL: Ascunde elementele ÎNAINTE de mutare
    this.hideContainerChildren(containerElement);

    // Ascunde header (footer rămâne pentru butoane)
    //this.headerElement?.classList.add('hidden');

    // ✅ Mută modal în container (ORDINE CORECTĂ)
    containerElement.appendChild(this.overlayElement);

    // Muta overlay înainte in parintele containerului
    containerElement.parentElement.appendChild(this.overlayElement);

    containerElement.appendChild(this.modalElement);

    // ✅ Aplică clase embedded ÎNAINTE de show
    this.overlayElement.classList.add('embedded-mode');
    this.modalElement.classList.add('embedded-mode');
    this.headerElement.classList.add('embedded-mode');

    // Open modal normal
    await this.openModal({ data: { rowId } });
  },

  /**
   * Ascunde copiii containerului (păstrează referințe pentru restore)
   */
  hideContainerChildren(container) {
    this.hiddenElements = Array.from(container.children)
      .filter((child) => child.id !== 'feedbackModalOverlay' && child.id !== 'feedbackModal')
      .map((child) => ({
        element: child,
        display: child.style.display || '',
      }));

    this.hiddenElements.forEach(({ element }) => {
      element.style.display = 'none';
    });

    this.log(`🙈 Ascunse ${this.hiddenElements.length} elemente din container`);
  },

  /**
   * Restaurează copiii containerului
   */
  restoreContainerChildren() {
    if (!this.hiddenElements) return;

    this.hiddenElements.forEach(({ element, display }) => {
      element.style.display = display;
    });

    this.log(`👁️ Restaurate ${this.hiddenElements.length} elemente în container`);
    this.hiddenElements = null;
  },

  /**
   * Restaurează modalul la starea normală (în body)
   */
  restoreFromEmbedded() {
    this.log('🔄 Restaurez modal din embedded mode');

    // Mută modal + overlay înapoi în originalParent
    this.originalParent.appendChild(this.overlayElement);
    this.originalParent.appendChild(this.modalElement);

    // Elimină clase embedded
    this.modalElement.classList.remove('embedded-mode');
    this.overlayElement.classList.remove('embedded-mode');
    this.headerElement.classList.remove('embedded-mode');

    // Restaurează elementele din container
    this.restoreContainerChildren();

    // Cleanup
    this.isEmbeddedMode = false;
    this.embeddedContainer = null;

    this.log('✅ Modal restaurat în body');
  },

  /**
   * Deschide modal (normal sau embedded)
   */
  async openModal(data) {
    const rowId = data?.data?.rowId;
    if (!rowId) {
      this.log.error('❌ Nu s-a furnizat rowId pentru deschiderea modal-ului');
      return;
    }

    this.log(`📂 Deschid modal pentru rowId: ${rowId}`);

    // Verifică dacă modalul e inițializat
    if (!this.isInitialized) {
      this.log('⚠️ Modal neinițializat, inițializez acum...');
      try {
        await this.init();
      } catch (error) {
        this.log.error('❌ Eroare la inițializarea modal-ului:', error);
        return;
      }
    }

    if (!this.modalElement || !this.overlayElement) {
      this.log.error('❌ Elementele modal-ului nu există');
      return;
    }

    this.currentRowId = rowId;

    // Populează status-urile (dacă sunt deja încărcate)
    if (this.statusData.length > 0) {
      this.populateStatusDropdown();
    }

    // Reset form
    this.resetForm();

    // Show modal
    this.overlayElement.classList.remove('hidden');
    this.overlayElement.classList.add('visible');
    this.modalElement.classList.remove('hidden');
    this.modalElement.classList.add('visible');

    this.overlayElement.style.zIndex = Math.floor(window.ZIndexManager.getNext()) + 5000 - 1;
    this.modalElement.style.zIndex = Math.floor(window.ZIndexManager.getNext()) + 5000;

    // Check spell checker și afișează banner dacă e cazul
    this.checkSpellChecker();

    this.modalElement.classList.add('zoom-in-start');

    // Trigger animation
    setTimeout(() => {
      this.modalElement.classList.remove('zoom-in-start');
      this.modalElement.classList.add('zoom-in-end');
    }, 10);

    // Focus pe status combobox
    setTimeout(() => {
      if (this.statusCombobox) {
        const comboInput = this.statusElement.querySelector('input');
        if (comboInput) {
          comboInput.focus();
        }
      } else {
        this.feedbackElement?.focus();
      }
    }, 300);

    this.isModalOpen = true;
    this.log('✅ Modal deschis cu succes');
  },

  /**
   * Închide modal (cu restore dacă embedded)
   */
  closeModal() {
    this.log('❌ Închid modal' + (this.isEmbeddedMode ? ' (embedded mode)' : ''));

    if (!this.isModalOpen) {
      this.log('⚠️ Modalul nu este deschis');
      return;
    }

    this.headerElement.classList.remove('with-status');
    this.footerElement.classList.remove('with-status');

    this.toolBarElement.querySelectorAll('.feedback-toolbar-btn').forEach((btn) => {
      btn.classList.remove('selected');
    });

    // 2. Distruge calendarul complet
    this.destroyCalendar();

    // Animație zoom-out
    this.modalElement.classList.remove('zoom-in-end');
    this.modalElement.classList.add('zoom-out');

    setTimeout(() => {
      this.modalElement.classList.add('hidden');
      this.overlayElement.classList.remove('visible');
      this.overlayElement.classList.add('hidden');
      this.modalElement.classList.remove('zoom-out');

      // Reset z-index
      this.overlayElement.style.zIndex = 0;
      this.modalElement.style.zIndex = 0;

      // Reset modal state
      // 3. Reset form complet
      this.resetForm();

      // 4. Dacă e embedded, restaurează
      if (this.isEmbeddedMode) {
        this.restoreFromEmbedded();
      }
    }, 250);

    // 5. Curăță variabilele de stare
    this.currentRowId = null;
    this.selectedStatus = null;
    this.isModalOpen = false;

    this.log('✅ Modal închis cu succes');
  },

  /**
   * Destroy complet al modal-ului (când nu mai e nevoie deloc)
   */
  destroyModal() {
    this.log('🗑️ DESTROY COMPLET modal');

    // Închide modalul mai întâi
    if (this.isModalOpen) {
      this.closeModal();
    }

    // Cleanup complet - TOȚI listenerii (DOM + BUS)
    this.cleanupAllListeners('all');

    // Șterge elementele din DOM
    if (this.modalElement) {
      this.modalElement.remove();
      this.modalElement = null;
    }

    if (this.overlayElement) {
      this.overlayElement.remove();
      this.overlayElement = null;
    }

    // Șterge CSS-ul dacă e cazul
    const cssLink = document.getElementById('feedbackModalCSS');
    if (cssLink) {
      cssLink.remove();
    }

    // Reset toate proprietățile
    this.isInitialized = false;
    this.currentRowId = null;
    this.statusData = [];
    this.selectedStatus = null;
    this.statusCombobox = null;

    // Distruge CalendarManager
    if (this.calendarManager) {
      this.calendarManager = null;
    }

    this.log('✅ Modal DESTROYED complet');
  },
};
