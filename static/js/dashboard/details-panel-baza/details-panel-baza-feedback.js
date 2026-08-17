// js/components/dashboard/details-panel-baza/details-panel-baza-feedback.js
/**
 * ========== DETAILS PANEL FEEDBACK - Gestionarea feedback-ului și cache-ului ==========
 * Conține toate funcțiile pentru încărcarea, cache-uirea și afișarea feedback-ului
 *
 * FUNCȚIONALITĂȚI:
 * ✅ Încărcare feedback de la server
 * ✅ Cache management pentru feedback
 * ✅ Renderizare tabel feedback
 * ✅ Gestionare stări de loading
 * ✅ Cleanup automat cache
 *
 * @version 2.0.0
 */
export const FeedbackManagerMixin = {
  /**
   * ÎNCĂRCARE FEEDBACK - Funcția principală pentru încărcarea feedback-ului
   */
  async loadFeedback(rowId) {
    this.log(`🔥 Încarc feedback pentru ID ${rowId}`);

    if (!this.department) {
      this.log.error('⚠️ Departamentul nu este setat în sessionData');
      return;
    }

    try {
      // Verifică cache-ul mai întâi
      // const cached = this.getCachedFeedback(rowId);
      // if (cached) {
      //   this.log('✅ Feedback găsit în cache');
      //   this.stats.cacheHits++;
      //   this.renderFeedbackTable(cached);
      //   return;
      // }

      this.stats.feedbackLoads++;

      // Emit evenimentul pentru încărcarea datelor
      this.eventBus.emit('extra-data-load-start', {
        endpoint: 'get_feedback',
        requestType: 'feedback',
        saveMode: 'append',
        idColumn: 'IdFeedBack',
        cache: false,
        timeout: 10000,
        department: this.department,
        searchColumn: 'IdBaza',
        IdBaza: rowId,
      });
    } catch (error) {
      this.log.error('Eroare la încărcarea feedback', error);
      this.renderFeedbackError();
    }
  },

  /**
   * PROCESARE FEEDBACK - Procesează datele primite de la server
   */
  processFeedback(receivedData, rowId = null) {
    try {
      if (receivedData && receivedData.results && receivedData.results.length > 0) {
        // Cache-uiește datele dacă avem rowId
        // if (rowId) {
        //   this.feedbackCacheFeedback(rowId, receivedData.results);
        // }

        this.renderFeedbackTable(receivedData.results);
      } else {
        this.renderFeedbackEmpty();
      }
    } catch (error) {
      this.log.error('Eroare la procesarea feedback', error);
      this.renderFeedbackError();
    }
  },

  /**
   * RENDERIZARE TABEL - Afișează datele de feedback în tabel
   */
  renderFeedbackTable(feedbackData) {
    if (!this.panelElement) {
      this.log.error('Panel element not found for feedback rendering');
      return;
    }

    const tbody = this.panelElement.querySelector('#feedbackTableBody');
    if (!tbody) {
      this.log.error('Feedback table body not found');
      return;
    }

    if (!feedbackData || feedbackData.length === 0) {
      this.renderFeedbackEmpty();
      return;
    }

    const html = feedbackData
      .map(
        (item) => `
      <tr style="background-color: ${item.BackColor || ''}">
        <td style="text-align: center; padding: 4px">${this.formatDate(item.DataConectare)}</td>
        <td class="feedback-cell" title="${helpers.stripHtmlForTooltip(item.FeedBack)}">${helpers.cleanAccessRichText(item.FeedBack)}</td>
        <td style="text-align: center; padding: 4px">${this.formatDate(item.DataReconectare)}</td>
      </tr>
    `
      )
      .join('');

    tbody.innerHTML = html;
    this.log(`✅ Tabel feedback renderizat cu ${feedbackData.length} înregistrări`);
  },

  /**
   * RENDERIZARE GOL - Afișează mesajul pentru feedback gol
   */
  renderFeedbackEmpty() {
    if (!this.panelElement) return;

    const tbody = this.panelElement.querySelector('#feedbackTableBody');
    if (tbody) {
      tbody.innerHTML = '<tr><td colspan="3" class="no-data">Nu există feedback</td></tr>';
    }
  },

  /**
   * RENDERIZARE EROARE - Afișează mesajul de eroare
   */
  renderFeedbackError() {
    if (!this.panelElement) return;

    const tbody = this.panelElement.querySelector('#feedbackTableBody');
    if (tbody) {
      tbody.innerHTML =
        '<tr><td colspan="3" class="error">Eroare la încărcarea feedback-ului</td></tr>';
    }
  },

  /**
   * CACHE FEEDBACK - Salvează feedback-ul în cache
   */
  cacheFeedback(rowId, data) {
    if (!rowId || !data) return;

    this.feedbackCache.set(rowId, {
      data,
      timestamp: Date.now(),
    });

    // Verifică dacă cache-ul nu depășește limita
    if (this.feedbackCache.size > this.config.maxCacheSize) {
      this.cleanupOldEntries();
    }
  },

  /**
   * OBȚINE FEEDBACK DIN CACHE - Returnează feedback-ul cache-uit dacă este valid
   */
  getCachedFeedback(rowId) {
    const cached = this.feedbackCache.get(rowId);

    if (!cached) return null;

    // Verifică dacă cache-ul nu a expirat
    if (Date.now() - cached.timestamp > this.config.cacheTimeout) {
      this.feedbackCache.delete(rowId);
      return null;
    }

    return cached.data;
  },

  /**
   * CLEANUP CACHE - Elimină intrările expirate
   */
  cleanupCache() {
    const now = Date.now();
    let removedCount = 0;

    this.feedbackCache.forEach((value, key) => {
      if (now - value.timestamp > this.config.cacheTimeout) {
        this.feedbackCache.delete(key);
        removedCount++;
      }
    });

    if (removedCount > 0) {
      console.log(`🧹 Cache cleanup: ${removedCount} intrări eliminate`);
    }

    return removedCount;
  },

  /**
   * CLEANUP INTRĂRI VECHI - Elimină cele mai vechi intrări dacă cache-ul e plin
   */
  cleanupOldEntries() {
    const entries = Array.from(this.feedbackCache.entries());

    // Sortează după timestamp (cel mai vechi primul)
    entries.sort((a, b) => a[1].timestamp - b[1].timestamp);

    // Elimină primele 20% din intrări
    const toRemove = Math.floor(entries.length * 0.2);

    for (let i = 0; i < toRemove; i++) {
      this.feedbackCache.delete(entries[i][0]);
    }

    console.log(`🧹 Cache cleanup: ${toRemove} intrări vechi eliminate`);
  },

  /**
   * PORNEȘTE AUTO CLEANUP - Pornește procesul automat de curățare
   */
  startAutoCleanup() {
    setInterval(() => {
      this.cleanupCache();
    }, this.config.cleanupInterval);
  },

  /**
   * ȘTERGE CACHE COMPLET - Elimină toate intrările din cache
   */
  clearCache() {
    const size = this.feedbackCache.size;
    this.feedbackCache.clear();
    console.log(`🗑️ Cache șters complet: ${size} intrări eliminate`);
  },

  /**
   * STATISTICI CACHE - Returnează statisticile cache-ului
   */
  getCacheStats() {
    const now = Date.now();
    let validEntries = 0;
    let expiredEntries = 0;

    this.feedbackCache.forEach((value) => {
      if (now - value.timestamp > this.config.cacheTimeout) {
        expiredEntries++;
      } else {
        validEntries++;
      }
    });

    return {
      totalEntries: this.feedbackCache.size,
      validEntries,
      expiredEntries,
      cacheTimeout: this.config.cacheTimeout,
      maxCacheSize: this.config.maxCacheSize,
    };
  },
};
