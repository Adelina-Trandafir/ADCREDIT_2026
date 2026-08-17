export const feedbackDataMixin = {
  /**
   * Handler pentru salvare
   */
  async handleSave() {
    this.log('💾 Salvez feedback...');

    // Setează loading
    this.setLoadingState(true);

    // Obține datele
    const editorData = this.getEditorContent();
    const statusData = this.getSelectedStatus();
    const selectedDate = this.getSelectedDate();

    const feedbackData = {
      rowId: this.currentRowId,
      IdStatus: statusData?.IdStatus,
      FelStatus: statusData?.FelStatus,
      feedback: editorData.html,
      feedbackText: editorData.text,
      dataRecontactare: selectedDate,
      // Pentru optimistic update
      DataConectare: new Date().toISOString(),
      BackColor: statusData?.BackColor || '#ffffff',
    };

    this.log('Date feedback:', feedbackData);

    try {
      // TODO: API call real
      // const response = await fetch('/api/save_feedback', {
      //   method: 'POST',
      //   headers: { 'Content-Type': 'application/json' },
      //   body: JSON.stringify(feedbackData)
      // });

      // Simulare success
      await new Promise((resolve) => setTimeout(resolve, 500));

      // Emit event pentru Details Panel
      this.eventBus.emit(this.EVENTS.DETAILS_PANEL_FEEDBACK_SAVED, feedbackData);

      this.log('✅ Feedback salvat și eveniment emis');

      // Close modal (va restaura tabelul dacă e embedded)
      this.closeModal();
    } catch (error) {
      this.log.error('Eroare la salvare', error);
    } finally {
      this.setLoadingState(false);
    }
  },

  /**
   * Handler pentru datele primite de la server (prin data-loader-extra.js)
   */
  handleExtraDataLoaded(eventData) {
    const { receivedData } = eventData.data;
    const requestType = receivedData.requestType || eventData.data.requestType;

    this.log(`🔨 Primite date pentru requestType: ${requestType}`, {
      dataSize: receivedData?.results?.length || 0,
    });

    if (!receivedData || !receivedData.success || !receivedData.results) {
      this.log.error(`⌫ Date invalide pentru requestType: ${requestType}`, receivedData);
      return;
    }

    // Procesează status-urile primite
    if (requestType === 'baza_status') {
      this.statusData = receivedData.results;
      this.log(`✅ ${this.statusData.length} status-uri încărcate în memorie`);

      // Dacă modal-ul e deja deschis, populează dropdown-ul
      if (this.modalElement && this.modalElement.classList.contains('active')) {
        this.populateStatusDropdown();
      }
    }
  },
};
