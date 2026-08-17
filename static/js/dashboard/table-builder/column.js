/**
 * 📊 COLUMN CLASS (unchanged logic)
 */
class Column {
  constructor(columnData) {
    // 🔧 PROPRIETĂȚI DE BAZĂ
    this.id = columnData.id;
    this.field = columnData.field;
    this.header = columnData.header;
    this.type = columnData.TipCamp;
    this.width = columnData.width;
    this.align = columnData.align || 'left';
    this.special = columnData.special || false;
    this.PK = columnData.PK;
    this.readOnlyCbx = columnData.js_readonly;
    this.NumeTabel = columnData.NumeTabel;
    this.Ascuns = columnData.Ascuns;
    this.AscunsInFiltru = columnData.AscunsInFiltru;
    this.Pozitie = columnData.Pozitie;
    this.CF = columnData.conditional_formatting;

    // 🎯 STATE MANAGEMENT
    this.hasFilter = false;
    this.filterConfig = null;
    this.filter = '';
    this.sortDirection = null;
    this.isHovered = false;
    this.isActive = false;

    // 📈 PERFORMANCE TRACKING
    this.clickCount = 0;
    this.lastClickTime = 0;
    this.hoverTime = 0;
    this.lastHoverStart = 0;
  }

  // 🔧 FILTER MANAGEMENT
  applyFilter(filterConfig) {
    this.hasFilter = true;
    this.filterConfig = filterConfig;
    this.log(`🔍 Filtru aplicat pe ${this.header}`);
  }

  clearFilter() {
    this.hasFilter = false;
    this.filterConfig = null;
    this.log(`🗑️ Filtru șters de pe ${this.header}`);
  }

  // 🔧 SORT MANAGEMENT
  setSortDirection(direction) {
    this.sortDirection = direction;
    this.log(`🔄 Sort ${direction} pe ${this.header}`);
  }

  clearSort() {
    this.sortDirection = null;
  }

  // 🎭 HOVER MANAGEMENT
  setHovered(hovered) {
    if (hovered && !this.isHovered) {
      this.lastHoverStart = Date.now();
    } else if (!hovered && this.isHovered) {
      this.hoverTime += Date.now() - this.lastHoverStart;
    }
    this.isHovered = hovered;
  }

  // 📊 CLICK TRACKING
  registerClick() {
    this.clickCount++;
    this.lastClickTime = Date.now();
  }

  // 📈 METRICS
  getMetrics() {
    return {
      clickCount: this.clickCount,
      lastClickTime: this.lastClickTime,
      totalHoverTime: this.hoverTime,
      hasFilter: this.hasFilter,
      sortDirection: this.sortDirection,
      isCurrentlyHovered: this.isHovered,
    };
  }

  // 🔧 SYNC CU GLOBAL STATE (pentru compatibilitate)
  syncToGlobalState() {
    if (this.hasFilter) {
      if (!window.activeFilters) window.activeFilters = {};
      window.activeFilters[this.id] = this.filterConfig;
    }

    if (this.sortDirection) {
      window.currentSort = {
        column: this.id,
        direction: this.sortDirection,
      };
    }
  }

  syncFromGlobalState() {
    // Sync filtru
    if (window.activeFilters && window.activeFilters[this.id]) {
      this.hasFilter = true;
      this.filterConfig = window.activeFilters[this.id];
    }

    // Sync sort
    if (window.currentSort && window.currentSort.column === this.id) {
      this.sortDirection = window.currentSort.direction;
    }
  }

  log(message) {
    console.log(`%c[Column ${this.id}] ${message}`, 'color: #8b5cf6');
  }
}

export default Column;
