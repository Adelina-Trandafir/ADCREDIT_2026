// js/components/dashboard/add-lead-modal/add-lead-ui.js
/**
 * 🎭 ADD LEAD UI MIXIN
 * Gestionează operațiunile UI ale modal-ului
 *
 * @version 1.0.0
 */

export const addLeadUIMixin = {
  /**
   * Deschide modal-ul
   */
  async openModal(data) {
    this.log('🔓 Deschid modal...');

    // Verifică dacă modal-ul e inițializat
    if (!this.isInitialized) {
      this.log('⚠️ Modal neinițializat, inițializez acum...');
      try {
        await this.init();
      } catch (error) {
        this.log.error('❌ Eroare la inițializarea modal-ului:', error);
        return;
      }
    }

    // Verifică dacă elementele există
    if (!this.containerElement) {
      this.log.error('❌ Elementele modal-ului nu există');
      return;
    }

    // Reset modal
    this.resetModal();

    this.containerElement.classList.remove('hidden');
    this.containerElement.classList.add('zoom-in-start');

    window.overlay.subscribe(this, this.containerElement, {
      onClick: () => this.closeModal(),
      onEscape: () => this.closeModal(),
      parent: document.getElementById('mainContainer'),
    });

    //this.containerElement.style.zIndex = Math.floor(window.ZIndexManager.getNext());

    // Trigger animation
    setTimeout(() => {
      this.containerElement.classList.remove('zoom-in-start');
      this.containerElement.classList.add('zoom-in-end');
    }, 10);

    // Focus pe input telefon
    setTimeout(() => {
      if (this.phoneInputElement) {
        this.phoneInputElement.focus();
      }
    }, 400);

    this.isModalOpen = true;
    this.log('✅ Modal deschis cu succes');
  },

  /**
   * Închide modal-ul
   */
  closeModal() {
    this.log('🔒 Închid modal...');

    if (!this.isModalOpen) {
      this.log('⚠️ Modalul nu este deschis');
      return;
    }

    // Animație zoom-out
    this.containerElement.classList.remove('zoom-in-end');
    this.containerElement.classList.add('zoom-out');

    window.overlay.unsubscribe(this);

    // După animație, ascunde complet
    setTimeout(() => {
      this.containerElement.classList.add('hidden');
      this.containerElement.classList.remove('zoom-out');

      // Reset z-index
      // this.containerElement.style.zIndex = 0;

      // Reset modal state
      this.resetModal();
    }, 250);

    this.isModalOpen = false;
    this.log('✅ Modal închis cu succes');
  },

  /**
   * Destroy complet modal (rar folosit)
   */
  destroyModal() {
    this.log('🗑️ DESTROY COMPLET modal');

    // Închide mai întâi
    if (this.isModalOpen) {
      this.closeModal();
    }

    // Cleanup listeners
    this.cleanupAllListeners('all');

    // Șterge elementele din DOM
    if (this.containerElement) {
      this.containerElement.remove();
      this.containerElement = null;
    }

    // Șterge CSS
    const cssLink = document.getElementById('addLeadModalCSS');
    if (cssLink) {
      cssLink.remove();
    }

    // Reset toate proprietățile
    this.isInitialized = false;
    this.isModalOpen = false;
    this.currentPhone = '';
    this.selectedCountry = null;
    this.tableData = [];
    this.selectedRow = null;
    this.actionType = null;
    this.countryCombobox = null;

    this.log('✅ Modal DESTROYED complet');
  },

  /**
   * Setează starea unui buton
   */
  setButtonState(buttonType, enabled) {
    let button = null;

    switch (buttonType) {
      case 'ok':
        button = this.okBtnElement;
        break;
      case 'vechi':
        button = this.vechiBtnElement;
        break;
      case 'nou':
        button = this.nouBtnElement;
        break;
      case 'cancel':
        button = this.cancelBtnElement;
        break;
    }

    if (button) {
      button.disabled = !enabled;
      this.log(`🔘 Buton ${buttonType}: ${enabled ? 'activat' : 'dezactivat'}`);
    }
  },

  /**
   * Arată secțiunea tabel cu animație
   */
  showTableSection() {
    if (this.tableSectionElement) {
      this.tableSectionElement.classList.remove('hidden');
      this.log('👁️ Secțiune tabel afișată');
    }
  },

  /**
   * Ascunde secțiunea tabel
   */
  hideTableSection() {
    if (this.tableSectionElement) {
      this.tableSectionElement.classList.add('hidden');
      this.log('🙈 Secțiune tabel ascunsă');
    }
  },

  /**
   * Handler pentru confirmarea finală
   */
  handleConfirm() {
    this.log('✅ Confirmare lead...');

    if (!this.actionType) {
      this.log.error('❌ Nu există tip de acțiune selectat');
      return;
    }

    // Pregătește datele pentru eveniment
    const eventData = {
      telefon: this.currentPhone,
      tara: this.selectedCountry.code,
      codTara: this.selectedCountry.dialCode,
      tipAdaugare: this.actionType,
      timestamp: Date.now(),
    };

    // Adaugă date extra pentru 'old_old' și 'old_new'
    if (this.actionType === 'old_old' && this.selectedRow) {
      eventData.clientData = {
        IdClient: this.selectedRow.IdClient,
        NumeClient: this.selectedRow.NumeClient,
        CNPClient: this.selectedRow.CNPClient,
        IdJudet: this.selectedRow.IdJudet,
        Judet: this.selectedRow.Judet,
        Tara: this.selectedRow.Tara,
        DataNastere: this.selectedRow.DataNastere,
      };
    }

    this.log('📤 Emit eveniment ADD_NEW_LEAD', eventData);

    // Emit eveniment
    this.eventBus.emit(this.EVENTS.ADD_NEW_LEAD, eventData);

    // Închide și destroy modal
    this.closeModal();
  },

  /**
   * Handler pentru buton Nou
   */
  handleNouClick() {
    this.log('➕ Click pe buton Nou');
    this.actionType = 'old_new';
    this.selectedRow = null;
    this.setButtonState('ok', true);
    this.setButtonState('vechi', false);

    // Deselect all rows
    this.clearRowSelection();
  },

  /**
   * Handler pentru buton Vechi
   */
  handleVechiClick() {
    this.log('♻️ Click pe buton Vechi');

    if (!this.selectedRow) {
      this.log.error('❌ Niciun rând selectat');
      return;
    }

    this.actionType = 'old_old';
    this.setButtonState('ok', true);
  },
};
