// js/modules/column_settings.js
import { API } from './api.js';
import { State } from './state.js';
import { UI } from './ui.js';
import { initDragDrop } from './dragDrop.js';
import { initKeyboard } from './keyboard.js';

// inițializăm starea și UI-ul
window.addEventListener('DOMContentLoaded', () => {
  initDragDrop(() => UI.render(State.columns));
  initKeyboard();
  loadColumns();
});

// expunem global minimul necesar
window.updateColumn = (idx, field, val) => {
  State.updateColumn(idx, field, val);
  UI.updateSaveButton();
};
window.toggleActionsMenu = (idx, e) => {
  e.stopPropagation();
  document.getElementById(`actions-${idx}`).classList.toggle('show');
};
window.duplicateColumn = (idx) => {
  const src = State.columns[idx];
  State.columns.forEach((c, i) => {
    if (i !== idx && c.NumeColoana.startsWith(src.NumeColoana.replace(/\d+$/, ''))) {
      Object.assign(c, {
        Afisare: src.Afisare,
        Marime: src.Marime,
        Aliniere: src.Aliniere,
        Formatare: src.Formatare,
      });
    }
  });
  UI.render(State.columns);
  State.check();
  UI.updateSaveButton();
  UI.message('Setări duplicate', 'success');
};
window.moveToTop = (idx) => move(idx, 0);
window.moveToBottom = (idx) => move(idx, State.columns.length - 1);

function move(from, to) {
  const [el] = State.columns.splice(from, 1);
  State.columns.splice(to, 0, el);
  State.columns.forEach((c, i) => (c.Pozitie = i + 1));
  UI.render(State.columns);
  State.check();
  UI.updateSaveButton();
}

async function loadColumns_for_settings() {
  UI.loading();
  try {
    const data = await API.getColumns(State.currentTab);
    State.reset(data.columns);
    UI.render(State.columns);
    UI.updateSaveButton();
  } catch (err) {
    UI.message(err.message, 'error');
  }
}

window.saveSettings = async () => {
  try {
    await API.saveColumns(State.currentTab, State.columns);
    State.reset(State.columns);
    UI.updateSaveButton();
    UI.message('Salvat!', 'success');
  } catch (err) {
    UI.message(err.message, 'error');
  }
};
window.resetToDefaults = async () => {
  if (!confirm('Resetați?')) return;
  try {
    await API.resetColumns(State.currentTab);
    await loadColumns();
  } catch (err) {
    UI.message(err.message, 'error');
  }
};

// tab-uri
document.querySelectorAll('.tab-btn').forEach((btn) =>
  btn.addEventListener('click', () => {
    if (State.hasChanges && !confirm('Modificări nesalvate! Continuați?')) return;
    document.querySelectorAll('.tab-btn').forEach((b) => b.classList.remove('active'));
    btn.classList.add('active');
    State.currentTab = btn.dataset.tab;
    loadColumns();
  })
);

// inițializări
// initDragDrop(() => UI.render(State.columns));
// initKeyboard();
// loadColumns();

window.loadColumns = loadColumns_for_settings;
