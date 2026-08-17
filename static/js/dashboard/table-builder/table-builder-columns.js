/**
 * 📊 TABLE BUILDER COLUMNS MIXIN
 * Gestionează coloanele: creare, calcul vizibilitate, evenimente
 *
 * @version 1.0.0
 */

export const tableBuilderColumnsMixin = {
  /**
   * 📊 CREARE COLUMN OBJECTS
   */
  createColumnObjects(Columns) {
    this.columns.clear();

    Columns.forEach((colData) => {
      const column = new this.Column(colData);
      this.columns.set(column.id, column);
    });

    this.log(`📊 Creat ${this.columns.size} Column objects`);
  },

  /**
   * 📐 CALCULEAZĂ COLOANE VIZIBILE
   */
  calculateVisibleColumns(metadata, availableSpaceOverhead = null) {
    const containerWidth = document.querySelector('.table-wrapper')?.clientWidth;

    let spaceAdjustment = 0;
    if (availableSpaceOverhead && typeof availableSpaceOverhead === 'object') {
      spaceAdjustment = availableSpaceOverhead.width || 0;
    }

    const available =
      containerWidth +
      (availableSpaceOverhead?.operation === 'subtract' ? -1 * spaceAdjustment : spaceAdjustment);

    let totalWidth = 30; // Record selector width
    const visible = [];

    for (let col of metadata) {
      const width = typeof col.width === 'string' ? parseFloat(col.width) : col.width;
      const effectiveWidth = width + this.extraColumnSpace;

      if (totalWidth + effectiveWidth <= available) {
        visible.push(col);
        totalWidth += effectiveWidth;
      } else {
        break;
      }
    }

    if (visible.length > 0) {
      const remaining = available - totalWidth;
      if (remaining > 0) {
        this.remainingSpace = remaining;
      }
    }

    this.log(`📊 Coloane calculate: ${visible.length}/${metadata.length}, spațiu: ${available}px`);
    return visible.length ? visible : metadata.slice(0, 1);
  },

  /**
   * 🎨 UPDATE VISUAL PENTRU COLOANĂ
   */
  updateColumnVisual(column) {
    const th = document.getElementById(`header-${column.id}`);
    if (!th) {
      console.warn(`Header pentru coloana ${column.id} nu a fost găsit`);
      return;
    }

    // Remove existing filter status icon
    const existingStatusIcon = document.getElementById(`filter-status-${column.id}`);
    if (existingStatusIcon) {
      this.removeFilterStatusListener(column, th);
      existingStatusIcon.remove();
    }

    // Add filter status icon if has filter
    if (column.hasFilter) {
      const statusArea = document.getElementById(`header-status-${column.id}`);
      if (statusArea) {
        const newStatusIcon = this.getFilterStatusIcon(column);
        const sortIcon = statusArea.querySelector('.sort-icon');
        if (sortIcon) {
          sortIcon.insertAdjacentHTML('beforebegin', newStatusIcon);
        } else {
          statusArea.insertAdjacentHTML('beforeend', newStatusIcon);
        }
        this.attachFilterStatusListener(column, th);
      }
    }

    // Update sort icon
    const sortIconId = `sort-icon-${column.id}`;
    const sortIcon = document.getElementById(sortIconId);
    if (sortIcon) {
      const newSortIcon = this.getSortIcon(column);
      sortIcon.outerHTML = newSortIcon;
    }
  },

  /**
   * 🎨 UPDATE ALL COLUMN VISUALS
   */
  updateAllColumnVisuals() {
    this.columns.forEach((column) => this.updateColumnVisual(column));
  },

  /**
   * 🧹 CLEAR COLUMN EVENT HANDLERS
   */
  clearColumnEventHandlers() {
    const columnHeaders = document.querySelectorAll('.column-header-clickable');
    columnHeaders.forEach((headerElement) => {
      this.removeDOMListener(headerElement);
    });
  },

  /**
   * 🎯 SETUP COLUMN EVENT HANDLERS
   */
  setupColumnEventHandlers(visibleColumns) {
    const columnHeaders = document.querySelectorAll('.column-header-clickable');

    columnHeaders.forEach((headerElement, index) => {
      const columnData = visibleColumns[index];
      const column = this.columns.get(columnData.id);

      this.addDOMListener(headerElement, 'click', (event) =>
        this.handleColumnClick(event, column, index, headerElement)
      );
    });

    this.log(`✅ Configurate event handlers pentru ${columnHeaders.length} coloane`);
  },

  /**
   * 🎨 ICON GENERATORS
   */
  getFilterOpenIcon(column) {
    return `<span id="filter-icon-${column.id}"
                class="filter-open-icon" 
                data-column="${column.id}" 
                title="Click pentru filtrare">🔍</span>`;
  },

  getSortIcon(column) {
    switch (column.sortDirection) {
      case 'asc':
        return `<span id="sort-icon-${column.id}" class="sort-icon" style="color: #007bff;" title="Sortat crescător">▲</span>`;
      case 'desc':
        return `<span id="sort-icon-${column.id}" class="sort-icon" style="color: #007bff;" title="Sortat descrescător">▼</span>`;
      default:
        return `<span id="sort-icon-${column.id}" class="sort-icon" style="color: #ccc;" title="Click pentru sortare"></span>`;
    }
  },

  getFilterStatusIcon(column) {
    if (!column.hasFilter) {
      column.hasFilter = true;
      this.log.error(`Filtru restabilit pentru coloana: ${column.header}`);
    }
    return `<span id="filter-status-${column.id}" class="filter-status-icon">🗑️</span>`;
  },

  /**
   * 🖱️ ATTACH/REMOVE FILTER STATUS LISTENER
   */
  attachFilterStatusListener(column, headerElement) {
    const filterStatusIcon = headerElement.querySelector(`#filter-status-${column.id}`);
    if (!filterStatusIcon) return;

    this.addClickListener(filterStatusIcon, (event) => this.handleClearFilterClick(event, column));
  },

  removeFilterStatusListener(column, headerElement) {
    const filterStatusIcon = headerElement.querySelector(`#filter-status-${column.id}`);
    if (!filterStatusIcon) return;

    const tooltip = document.querySelector('.filter-tooltip');
    if (tooltip) tooltip.remove();
  },

  /**
   * 📊 GETTERS
   */
  getColumnById(columnId) {
    return this.columns.get(columnId);
  },

  getAllVisibleColumns() {
    return Array.from(this.columns.values());
  },

  getColumnsWithFilters() {
    return Array.from(this.columns.values()).filter((col) => col.hasFilter);
  },

  getColumnsWithSort() {
    return Array.from(this.columns.values()).filter((col) => col.sortDirection);
  },
};
