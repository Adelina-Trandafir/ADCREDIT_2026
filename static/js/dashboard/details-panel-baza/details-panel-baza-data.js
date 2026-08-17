export const DataProcessorsMixin = {
  // ============================================================================
  // 📊 GESTIONAREA DATELOR EXTERNE
  // ============================================================================
  handleExtraDataLoaded(eventData) {
    const { receivedData } = eventData.data;
    const { requestType } = receivedData;
    let res = null;

    this.log(`🔨 Primite date pentru requestType: ${requestType}`, {
      dataSize: receivedData?.results?.length || 0,
    });

    if (!receivedData || !receivedData.success || !receivedData.results) {
      this.log.error(`❌ Date invalide pentru requestType: ${requestType}`, receivedData);
      return;
    }

    // Delegă procesarea către modulul de date
    if (requestType === 'judete') {
      res = this.processJudete(receivedData, this.components.comboboxJudet, this.log);
      if (res) {
        //this.setElementLoadingState('JudetClient', false);
      }
    } else if (requestType === 'surse_agenti') {
      res = this.cachedSurseData = this.processSurseAgenti(
        receivedData,
        this.components.treeviewSursa,
        this.log
      );
      if (res) {
        //this.setElementLoadingState('SursaAgent', false);
      }
    } else if (requestType === 'consultanti') {
      res = this.processConsultanti(receivedData, this.components.treeviewConsultant);
      if (res) {
        // this.setElementLoadingState('NumeConsultant', false);
      }
    } else if (requestType === 'feedback') {
      this.processFeedback(receivedData, this.currentRowId);
    }
  },

  /**
   * Procesează lista de județe primită de la server
   * @param {Object} receivedData - Datele primite cu lista de județe
   * @param {Object} comboboxJudet - Referința la componenta combobox
   */
  processJudete(receivedData, comboboxJudet) {
    try {
      if (comboboxJudet) {
        comboboxJudet.options.staticData = receivedData.results.map((item) => ({
          value: item.IdJudet,
          label: item.Judet,
        }));

        // Setup search functionality
        comboboxJudet.options.onSearch = async (query) => {
          const filtered = comboboxJudet.options.staticData.filter((item) =>
            item.label.toLowerCase().includes(query.toLowerCase())
          );
          return filtered;
        };
      }

      this.log(`✅ Județe procesate cu succes: ${receivedData.results.length} intrări`);

      return true;
    } catch (error) {
      this.log.error('⌫ Eroare la procesarea județelor', error);

      return false;
    }
  },

  /**
   * Procesează lista de surse și agenți primită de la server
   * @param {Object} receivedData - Datele primite cu lista de surse/agenți
   * @param {Object} treeviewSursa - Referința la componenta treeview
   * @returns {Array} Datele procesate pentru cache
   */
  processSurseAgenti(receivedData, treeviewSursa) {
    try {
      const treeData = this.buildSurseAgentiTree(receivedData.results);

      if (treeviewSursa) treeviewSursa.updateResults(treeData, '');

      this.log(`✅ Surse procesate cu succes: ${receivedData.results.length} intrări`);

      return treeData; // Pentru cache
    } catch (error) {
      this.log.error('⌫ Eroare la procesarea surselor', error);

      return null;
    } finally {
      //this.setElementLoadingState('SursaAgent', false);
    }
  },

  /**
   * Procesează lista de consultanți primită de la server
   * @param {Object} receivedData - Datele primite cu lista de consultanți
   * @param {Object} treeviewConsultant - Referința la componenta treeview
   */
  processConsultanti(receivedData, treeviewConsultant) {
    try {
      const treeData = this.buildConsultantsTree(receivedData.results);

      if (treeviewConsultant) treeviewConsultant.updateResults(treeData, '');

      this.log(`✅ Arbore consultanți încărcat: ${receivedData.results.length} înregistrări`);
      return true;
    } catch (error) {
      this.log.error('Eroare la procesarea consultanților', error);
      return false;
    } finally {
      //this.setElementLoadingState('Consultanti', false);
    }
  },

  /**
   * Procesează datele de feedback primite de la server
   * @param {Object} receivedData - Datele primite cu feedback-ul
   * @param {Function} renderFunction - Funcția pentru renderizarea tabelului
   * @param {Function} handleError - Funcția pentru gestionarea erorilor
   */
  processFeedback(receivedData) {
    try {
      this.renderFeedbackTable(receivedData.results);
    } catch (error) {
      this.log.error('Eroare la încărcarea feedback', error);
      this.renderFeedbackError();
    }
  },

  /**
   * Renderizează tabelul de feedback cu datele primite
   * @param {Array} feedbackData - Datele de feedback
   * @param {HTMLElement} panelElement - Elementul panelului
   * @returns {void}
   */
  renderFeedbackTable(feedbackData) {
    const tbody = this.panelElement.querySelector('#feedbackTableBody');

    if (!feedbackData || feedbackData.length === 0) {
      tbody.innerHTML = '<tr><td colspan="3" class="no-data">Nu există feedback</td></tr>';
      return;
    }

    const html = feedbackData
      .map(
        (item) => `
      <tr style="background-color: ${item.BackColor || ''}">
        <td style="text-align: center; padding: 4px">${this.formatDate(item.DataConectare)}</td>
        <td class="feedback-cell" title="${this.stripHtmlForTooltip(item.FeedBack)}">${this.cleanAccessRichText(item.FeedBack)}</td>
        <td style="text-align: center; padding: 4px">${this.formatDate(item.DataReconectare)}</td>
      </tr>
    `
      )
      .join('');

    tbody.innerHTML = html;
  },

  /**
   * Renderizează mesajul de eroare în tabelul de feedback
   * @param {HTMLElement} panelElement - Elementul panelului
   */
  renderFeedbackError(panelElement) {
    const tbody = this.panelElement.querySelector('#feedbackTableBody');
    tbody.innerHTML =
      '<tr><td colspan="3" class="error">Eroare la încărcarea feedback-ului</td></tr>';
  },

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
   * Handler pentru feedback salvat - optimistic update
   */
  async handleFeedbackSaved(eventData) {
    const { rowId, feedback, DataConectare, BackColor, dataRecontactare } = eventData;

    // Verifică dacă e pentru row-ul curent
    if (rowId !== this.currentRowId) {
      return;
    }

    this.log('✅ Feedback salvat, actualizez tabelul...', eventData);

    // Optimistic update - adaugă randul nou
    const newRow = {
      DataConectare: DataConectare || new Date().toISOString(),
      FeedBack: feedback,
      DataReconectare: dataRecontactare || null,
      BackColor: BackColor || '#ffffff',
    };

    // Inserează în tabel (prepend - cel mai recent sus)
    this.prependFeedbackRow(newRow);

    // Show success message
    this.showFeedbackSuccessMessage();

    // Invalidate cache pentru reload la următoarea deschidere
    const cacheKey = `feedback_${rowId}`;
    if (this.feedbackCache && this.feedbackCache.has(cacheKey)) {
      this.feedbackCache.delete(cacheKey);
      this.log('🗑️ Cache invalidat pentru rowId:', rowId);
    }
  },

  /**
   * Inserează un rând nou în tabelul de feedback (la început)
   */
  prependFeedbackRow(feedbackItem) {
    const tbody = this.panelElement.querySelector('#feedbackTableBody');
    if (!tbody) {
      this.log.error('❌ Tbody feedback nu există');
      return;
    }

    // Elimină "nu există feedback" dacă există
    const noDataRow = tbody.querySelector('td.no-data, td.loading');
    if (noDataRow) {
      noDataRow.parentElement.remove();
    }

    // Creează randul nou
    const newRow = document.createElement('tr');
    newRow.style.backgroundColor = feedbackItem.BackColor || '';
    newRow.innerHTML = `
      <td style="text-align: center; padding: 4px">${this.formatDate(feedbackItem.DataConectare)}</td>
      <td class="feedback-cell" title="${this.stripHtmlForTooltip(feedbackItem.FeedBack)}">${this.cleanAccessRichText(feedbackItem.FeedBack)}</td>
      <td style="text-align: center; padding: 4px">${this.formatDate(feedbackItem.DataReconectare)}</td>
    `;

    // Inserează la început
    tbody.insertBefore(newRow, tbody.firstChild);

    // Animație fade-in
    newRow.style.animation = 'feedbackRowFadeIn 0.4s ease';

    this.log('✅ Rând nou adăugat în tabelul de feedback');
  },

  /**
   * Afișează banner de success
   */
  showFeedbackSuccessMessage() {
    const feedbackContainer = document.getElementById('feedbackTableContainer');
    if (!feedbackContainer) return;

    // Verifică dacă există deja un banner
    const existingBanner = feedbackContainer.querySelector('.feedback-success-banner');
    if (existingBanner) {
      existingBanner.remove();
    }

    // Creează success banner
    const banner = document.createElement('div');
    banner.className = 'feedback-success-banner';
    banner.textContent = '✔ Feedback salvat cu succes';
    banner.style.cssText = `
      position: absolute;
      top: 10px;
      left: 50%;
      transform: translateX(-50%);
      background: #4CAF50;
      color: white;
      padding: 12px 24px;
      border-radius: 4px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.2);
      z-index: 1000;
      animation: slideDown 0.3s ease-out;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      font-size: 14px;
      font-weight: 500;
    `;

    feedbackContainer.style.position = 'relative';
    feedbackContainer.appendChild(banner);

    // Auto remove după 3 secunde
    setTimeout(() => {
      banner.style.animation = 'slideUp 0.3s ease-out';
      setTimeout(() => banner.remove(), 300);
    }, 3000);
  },

  handleSourceAgentSelectionChange(selectedNode) {
    if (!selectedNode) return;

    const { eventBus, EVENTS } = this;
    const department = this.sessionData.get('Department');

    // 1️⃣ Creezi promise-ul care așteaptă eventul "EXTRA_DATA_LOAD_FINISHED"
    const waitForExtraData = new Promise((resolve, reject) => {
      const onFinished = (data) => {
        eventBus.off(EVENTS.EXTRA_DATA_SEARCH_COMPLETE, onFinished); // curățare ascultător
        resolve(data);
      };

      const onError = (err) => {
        eventBus.off(EVENTS.EXTRA_DATA_ERROR, onError);
        reject(err);
      };

      eventBus.on(EVENTS.EXTRA_DATA_SEARCH_COMPLETE, onFinished);
      eventBus.on(EVENTS.EXTRA_DATA_ERROR, onError);
    });

    // 2️⃣ Emite evenimentul care pornește încărcarea
    eventBus.emit(EVENTS.EXTRA_DATA_SEARCH_START, {
      endpoint: 'get_surse_agenti',
      requestType: 'surse_agenti',
      cache: true,
      timeout: 10000,
      department,
      searchColumn: 'IDAgent',
      searchValue: selectedNode.id,
      idColumn: 'IDAgent',
    });

    this.log('🔍 Sursa agent selectată:', selectedNode);

    // 3️⃣ Când promise-ul e gata, rulează codul dorit
    waitForExtraData
      .then((data) => {
        if (!data || !data.data.receivedData.success) {
          this.log.error('❌ Date invalide primite la server:', data);
          return;
        }

        const results = data.data.receivedData.results || [];

        if (results.length > 1) {
          this.log(
            '⚠️ Atenție: Mai multe înregistrări primite pentru sursa agent selectată:',
            results
          );
        }

        this.components.formInputs.get('aTelefon').value = results[0].aTelefon || '';
        this.components.formInputs.get('aMail').value = results[0].aMail || '';

        this.sendMailBtnElement.disabled = results[0].aMail === '';
      })
      .catch((err) => {
        this.log.error('❌ Eroare la EXTRA_DATA_LOAD:', err);
        this.sendMailBtnElement.disabled = true;
      });
  },
};
