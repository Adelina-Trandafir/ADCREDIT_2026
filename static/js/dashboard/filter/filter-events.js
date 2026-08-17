// File: static/js/dashboard/filter/filter-events.js

/*
 * 📡 FILTER EVENTS MIXIN
 * Mixin pentru gestionarea evenimentelor legate de fereastra modală de filtrare.
 *
 *  * RESPONSABILITĂȚI:
 * ✅ Setup event listeners
 *
 * @version 4.0.0
 */

export const filterEventsMixin = {
  /**
   * 🔌 SETUP EVENT LISTENERS
   */
  setupModalEventListeners() {
    if (this.areModalEventListenersSet) return;

    this.addClickListener(this.applyBtnElement, () => this.handleApplyBtnClick());
    this.addClickListener(this.clearBtnElement, () => this.handleClearBtnClick());
    this.addDOMListener(this.partialTextElement, 'keypress', (event) => {
      if (event.key === 'Enter') this.handleApplyBtnClick();
      if (event.key === 'Escape' && this.modal.style.display === 'block') this.hideModal();
    });

    // Radio buttons
    Object.values(this.optionButtons).forEach((radio) => {
      this.addDOMListener(radio, 'change', (e) => this.handleAccordionChange(e.target.value));
    });

    this.addDOMListener(this.modalElement, 'keydown', (e) => {
      if (e.key === 'Escape' && this.modalElement.style.display === 'block') {
        this.hideModal();
      }
    });

    this.areModalEventListenersSet = true;
  },

  setupBUSListeners() {
    if (this.areBUSListenersSet) return;
    this.addBusListener(EVENTS.FILTER_CLOSE_WINDOW, (filterData) => this.hideModal(filterData));
    this.addBusListener(EVENTS.FILTER_SHOW_WINDOW, (filterData) => {
      if (filterData.data?.source === 'filter-panel') {
        this.showNormal(filterData, 'filter-panel');
      } else {
        this.showModal(filterData);
      }
    });
    // this.addBusListener(EVENTS.FILTER_APPLY, (filterData) => this.handleApplyFilter(filterData));

    // Primeste evenimentul de la click pe header filter clear
    this.addBusListener(EVENTS.FILTER_CLEAR, (filterData) => this.handleClearFilter(filterData));

    this.addBusListener(EVENTS.FILTER_FETCH_COLUMN_VALUES, async (e) => {
      const { filterData, columnData, requestId } = e.data;
      try {
        const response = await fetch('/api/column-values', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            tab: this.getInstance('Tabs').currentTab,
            column: columnData.field,
            limit: 50,
            PK: columnData.PK,
            filtru: filterData || '',
            NumeTabel: columnData.NumeTabel,
          }),
        });
        if (!response.ok) {
          this.eventBus.emit(EVENTS.FILTER_FETCH_COLUMN_VALUES_ERROR, { requestId, error: response.statusText });
          return;
        }
        const data = await response.json();
        const results = (data.values || []).map((o) => ({ value: o['0'], label: o['1'] }));
        this.eventBus.emit(EVENTS.FILTER_FETCH_COLUMN_VALUES_SUCCESS, { requestId, results });
      } catch (error) {
        this.eventBus.emit(EVENTS.FILTER_FETCH_COLUMN_VALUES_ERROR, { requestId, error: error.message });
      }
    });

    this.areBUSListenersSet = true;
  },
};
