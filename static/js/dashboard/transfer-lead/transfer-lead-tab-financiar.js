/**
 * TRANSFER LEAD - TAB FINANCIAR
 * Construieste si gestioneaza continutul tab-ului FINANCIAR.
 */

import eventBus, { EVENTS } from '../../event-bus/event-bus.js';
import { Combobox } from '../../components/combobox/combobox.js';

/**
 * Construieste HTML-ul sectiunii tab FINANCIAR.
 * NU instantiaza combobox-urile - doar creeaza structura DOM.
 * @param {Object} manager
 * @returns {HTMLElement}
 */
async function buildFinanciarContent(manager) {
  const div = document.createElement('div');
  div.className = 'tl-tab-financiar';

  div.innerHTML = `
    <!-- TIP VENIT -->
    <div class="tl-tab-section-header">TIP VENIT</div>
    <div class="tl-tab-row">
      <label for="tl-tip-venit">Tip Venit</label>
      <div id="tl-tip-venit" style="flex:1;min-width:0;"></div>
      <input type="text" id="tl-val-venit" class="tl-val-input" placeholder="LEI" />
      <span class="tl-lbl-lei">LEI</span>
    </div>

    <!-- TIP IMOBIL -->
    <div class="tl-tab-section-header">TIP IMOBIL</div>
    <div class="tl-tab-row">
      <label for="tl-tip-imobil">Tip Imobil</label>
      <div id="tl-tip-imobil" style="flex:1;min-width:0;"></div>
    </div>
    <div class="tl-tab-row">
      <label for="tl-are-imobil">Are?</label>
      <input type="checkbox" id="tl-are-imobil" />
      <input type="text" id="tl-val-imobil" class="tl-val-input" placeholder="LEI" />
      <span class="tl-lbl-lei">LEI</span>
    </div>

    <!-- TIP CREDIT -->
    <div class="tl-tab-section-header">TIP CREDIT</div>
    <div class="tl-tab-row">
      <label for="tl-tip-credit">Tip Credit</label>
      <div id="tl-tip-credit" style="flex:1;min-width:0;"></div>
    </div>
    <div class="tl-tab-row">
      <label for="tl-perioada">Perioad\u0103</label>
      <input type="number" id="tl-perioada" class="tl-val-input" placeholder="Luni" min="1" />
    </div>
    <div class="tl-tab-row">
      <label for="tl-moneda">Moned\u0103</label>
      <div id="tl-moneda" style="flex:1;min-width:0;"></div>
    </div>
    <div class="tl-tab-row">
      <label>Valoare</label>
      <input type="text" id="tl-val-credit" class="tl-val-input" placeholder="LEI" />
      <span class="tl-lbl-lei">LEI</span>
    </div>

    <!-- TIP DOBANDA -->
    <div class="tl-tab-section-header">TIP DOB\u00c2ND\u0102</div>
    <div class="tl-tab-row">
      <label for="tl-tip-dobanda">Tip Dob\u00e2nd\u0103</label>
      <div id="tl-tip-dobanda" style="flex:1;min-width:0;"></div>
    </div>
  `;

  return div;
}

/**
 * Apelat la prima activare a tab-ului.
 * Instantiaza combobox-urile si ataseaza listeneri.
 * @param {Object} manager
 */
async function activateFinanciar(manager) {
  if (manager.financiarComponentsInit) return;

  const contentArea = manager.panelElement.querySelector('[data-tab-content="financiar"]');
  if (!contentArea) return;

  const comboConfigs = [
    { id: 'tl-tip-venit',    requestType: 'tl_tipuri_venit' },
    { id: 'tl-tip-imobil',   requestType: 'tl_tipuri_imobil' },
    { id: 'tl-tip-credit',   requestType: 'tl_tipuri_credit' },
    { id: 'tl-moneda',       requestType: 'tl_monede' },
    { id: 'tl-tip-dobanda',  requestType: 'tl_tipuri_dobanda' },
  ];

  if (!manager.components.financiar) {
    manager.components.financiar = new Map();
  }

  comboConfigs.forEach(({ id, requestType }) => {
    const el = contentArea.querySelector(`#${id}`);
    if (!el) return;

    const combo = new Combobox(el, {
      placeholder: 'Selecteaz\u0103...',
      readonly: true,
      staticData: manager.pendingComboData.get(id) || [],
      onSelect: (value, text) => {
        eventBus.emit(EVENTS.USER_ACTIVITY);
        manager.formData[requestType] = value;
      },
    });

    // Aplica date pending daca exista
    if (manager.pendingComboData.has(id)) {
      combo.options.staticData = manager.pendingComboData.get(id);
      manager.pendingComboData.delete(id);
    }

    manager.components.financiar.set(id, combo);
  });

  // Listeneri pe input-urile numerice pentru USER_ACTIVITY si markDirty
  ['tl-val-venit', 'tl-val-imobil', 'tl-val-credit', 'tl-perioada'].forEach((inputId) => {
    const el = contentArea.querySelector(`#${inputId}`);
    if (!el) return;
    manager.addDOMListener(el, 'input', () => {
      eventBus.emit(EVENTS.USER_ACTIVITY);
      manager.isDirty = true;
      const saveBtn = manager.panelElement.querySelector('#tl-btn-save');
      if (saveBtn) saveBtn.disabled = false;
    });
  });

  manager.financiarComponentsInit = true;
}

export const FINANCIAR_TAB_CONFIG = {
  id: 'financiar',
  label: 'FINANCIAR',
  icon: '\ud83d\udcb3',
  order: 1,
  buildContent: buildFinanciarContent,
  onActivate: activateFinanciar,
  onDeactivate: () => {},
};
