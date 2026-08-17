// js/modules/state.js
// variabile reactive + helpers
export const State = {
  columns: [],
  original: [],
  currentTab: 'nvB1',
  hasChanges: false,

  reset(columns) {
    this.columns = columns;
    this.original = JSON.parse(JSON.stringify(columns));
    this.hasChanges = false;
  },

  updateColumn(index, field, value) {
    this.columns[index][field] = value;
    this.columns[index].Pozitie = index + 1; // recalculează automat
    this.check();
  },

  check() {
    this.hasChanges = JSON.stringify(this.columns) !== JSON.stringify(this.original);
  },
};
