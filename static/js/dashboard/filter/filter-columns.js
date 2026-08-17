export const filterColumnsMixin = {
  /**
   * 🎨 VISUAL UPDATES
   */
  updateFilterVisual(columnId, isActive) {
    try {
      const th = this.headerElement;
      if (!th) return;

      const filterIcon = th.querySelector('.filter-icon');
      if (!filterIcon) return;

      if (isActive) {
        filterIcon.classList.add('filter-active');
        filterIcon.style.color = '#059669';
        filterIcon.title = 'Filtru activ - Click pentru editare';
        th.classList.add('column-filtered');
      } else {
        filterIcon.classList.remove('filter-active');
        filterIcon.style.color = '#6b7280';
        filterIcon.title = 'Click pentru filtrare';
        th.classList.remove('column-filtered');
      }
    } catch (error) {
      this.handleError('Eroare la actualizarea vizualului filtrului', error);
    }
  },

  updateAllFilterVisuals() {
    // Actualizează pentru filtrele active
    this.activeFilters.forEach((filterConfig, columnId) => {
      this.updateFilterVisual(columnId, true);
    });

    // Actualizează pentru coloanele fără filtre
    const allVisibleColumns = document.querySelectorAll('th[data-column]');
    allVisibleColumns.forEach((th) => {
      const columnId = th.dataset.column;
      if (!this.activeFilters.has(columnId)) {
        this.updateFilterVisual(columnId, false);
      }
    });
  },
};
