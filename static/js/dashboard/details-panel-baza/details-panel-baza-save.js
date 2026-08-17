export const PanelSaveOpsMixin = {
  showFeedbackSuccessMessage() {
    const feedbackContainer = document.getElementById('feedbackTableContainer');
    if (!feedbackContainer) return;

    // Create success banner
    const banner = document.createElement('div');
    banner.className = 'feedback-success-banner';
    banner.textContent = '✓ Feedback salvat cu succes';
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
  `;

    feedbackContainer.style.position = 'relative';
    feedbackContainer.appendChild(banner);

    // Auto remove după 3 secunde
    setTimeout(() => {
      banner.style.animation = 'slideUp 0.3s ease-out';
      setTimeout(() => banner.remove(), 300);
    }, 3000);
  },

  async handleFeedbackSaved(eventData) {
    const { rowId, feedback, timestamp } = eventData;

    // Verifică dacă e pentru row-ul curent
    if (rowId !== this.currentRowId) {
      return;
    }

    console.log('Feedback saved, reloading feedback table...', eventData);

    // Invalidate cache pentru acest rowId
    const cacheKey = `feedback_${rowId}`;
    if (this.feedbackCache && this.feedbackCache.has(cacheKey)) {
      this.feedbackCache.delete(cacheKey);
    }

    // Reload feedback table
    await this.loadFeedback(rowId);

    // Optional: Show success message
    this.showFeedbackSuccessMessage();
  },
};
