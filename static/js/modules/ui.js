// js/modules/ui.js
//manipulare DOM + mesaje
import { State } from './state.js';

export const UI = {
  container: () => document.getElementById('columnsContainer'),
  saveBtn: () => document.querySelector('.save-btn'),
  saveInfo: () => document.getElementById('saveInfo'),

  render(columns) {
    if (!columns.length) {
      this.container().innerHTML = /* html */ `
        <div class="empty-state">
          <svg>...</svg>
          <h3>Nu există coloane configurate</h3>
          <p>Contactați administratorul</p>
        </div>`;
      return;
    }

    let html = /* html */ `
      <div class="header-row">
        <div></div><div>Nume Coloană</div><div>Nume Afișat</div>
        <div>Poziție</div><div>Lățime (px)</div><div>Aliniere</div>
        <div>Formatare</div><div>Ascuns</div><div></div>
      </div>`;

    columns.forEach((col, idx) => {
      html += /* html */ `
        <div class="column-item ${col.Ascuns ? 'hidden' : ''}"
             data-index="${idx}" data-name="${col.NumeColoana}" draggable="true">
          <div class="drag-handle">⋮⋮</div>
          <div>
            <div class="column-name">${col.NumeColoana}</div>
            ${col.Descriere ? `<div class="column-description">${col.Descriere}</div>` : ''}
          </div>
          <input type="text"   value="${col.Afisare || ''}"
                 onchange="window.updateColumn(${idx},'Afisare',this.value)">
          <input type="number" value="${col.Pozitie}"
                 onchange="window.updateColumn(${idx},'Pozitie',+this.value)"
                 min="1" max="999">
          <input type="number" value="${col.Marime ?? 100}" min="50" max="500" step="10"
                 onchange="window.updateColumn(${idx},'Marime',+this.value)"
                 min="50" max="500" step="10">
          <select onchange="window.updateColumn(${idx},'Aliniere',+this.value)">
            <option value="0" ${col.Aliniere === 0 ? 'selected' : ''}>Stânga</option>
            <option value="1" ${col.Aliniere === 1 ? 'selected' : ''}>Centru</option>
            <option value="2" ${col.Aliniere === 2 ? 'selected' : ''}>Dreapta</option>
          </select>
          <select class="format-select"
                  onchange="window.updateColumn(${idx},'Formatare',this.value)">
            <option value="" ${!col.Formatare ? 'selected' : ''}>Text</option>
            <option value="NUMBER" ${col.Formatare === 'NUMBER' ? 'selected' : ''}>Număr</option>
            <option value="CURRENCY" ${col.Formatare === 'CURRENCY' ? 'selected' : ''}>Valută</option>
            <option value="DATE" ${col.Formatare === 'DATE' ? 'selected' : ''}>Dată</option>
            <option value="PERCENT" ${col.Formatare === 'PERCENT' ? 'selected' : ''}>Procent</option>
          </select>
          <input type="checkbox"
                 ${col.Ascuns ? 'checked' : ''}
                 onchange="window.updateColumn(${idx},'Ascuns',this.checked)}">
          <div class="actions-menu">
            <button class="actions-btn"
                    onclick="window.toggleActionsMenu(${idx},event)">⋮</button>
            <div class="actions-dropdown" id="actions-${idx}">
              <button onclick="window.duplicateColumn(${idx})">Duplică</button>
              <button onclick="window.moveToTop(${idx})">Început</button>
              <button onclick="window.moveToBottom(${idx})">Sfârșit</button>
            </div>
          </div>
        </div>`;
    });
    this.container().innerHTML = html;
  },

  loading() {
    this.container().innerHTML = `
      <div class="loading">
        <div class="spinner"></div><p>Se încarcă coloanele...</p>
      </div>`;
  },

  updateSaveButton() {
    const btn = this.saveBtn();
    const info = this.saveInfo();
    btn.disabled = !State.hasChanges;
    if (State.hasChanges) {
      info.textContent = 'Aveți modificări nesalvate';
      info.classList.add('has-changes');
    } else {
      info.textContent = 'Toate modificările sunt salvate';
      info.classList.remove('has-changes');
    }
  },

  message(text, type = 'info') {
    const m = document.createElement('div');
    m.className = `message ${type}`;
    m.textContent = text;
    document.body.appendChild(m);
    setTimeout(() => m.remove(), 3000);
  },
};
