/**
 * TRANSFER LEAD - TAB BANCAR
 * Construieste si gestioneaza continutul tab-ului BANCAR.
 */

import eventBus, { EVENTS } from '../../event-bus/event-bus.js';
import { Combobox } from '../../components/combobox/combobox.js';

/**
 * Construieste HTML-ul sectiunii tab BANCAR.
 * @param {Object} manager
 * @returns {HTMLElement}
 */
async function buildBancarContent(manager) {
  const div = document.createElement('div');
  div.className = 'tl-tab-bancar';

  div.innerHTML = `
    <!-- BANCA -->
    <div class="tl-tab-section-header">BANC\u0102 \\ SUCURSAL\u0102</div>
    <div class="tl-tab-row">
      <label for="tl-banca">Banc\u0103</label>
      <div id="tl-banca" style="flex:1;min-width:0;"></div>
    </div>
    <div class="tl-tab-row">
      <label for="tl-cod-banca">Cod Banc\u0103</label>
      <input type="text" id="tl-cod-banca" readonly placeholder="" style="flex:1;" />
    </div>

    <!-- CONSILIER BANCA -->
    <div class="tl-tab-section-header">CONSILIER BANC\u0102</div>
    <div class="tl-tab-row">
      <label for="tl-consilier-banca">Consilier</label>
      <div id="tl-consilier-banca" style="flex:1;min-width:0;"></div>
    </div>

    <!-- EVALUATOR -->
    <div class="tl-tab-section-header">EVALUATOR</div>
    <div class="tl-tab-row">
      <label for="tl-evaluator">Evaluator</label>
      <div id="tl-evaluator" style="flex:1;min-width:0;"></div>
    </div>

    <!-- NOTAR -->
    <div class="tl-tab-section-header">NOTAR</div>
    <div class="tl-tab-row">
      <label for="tl-notar">Notar</label>
      <div id="tl-notar" style="flex:1;min-width:0;"></div>
    </div>
  `;

  return div;
}

/**
 * Apelat la prima activare a tab-ului BANCAR.
 * @param {Object} manager
 */
async function activateBancar(manager) {
  if (manager.bancarComponentsInit) return;

  const contentArea = manager.panelElement.querySelector('[data-tab-content="bancar"]');
  if (!contentArea) return;

  if (!manager.components.bancar) {
    manager.components.bancar = new Map();
  }

  // Combobox Banca - cu handler pentru cod + consilier
  const bancaEl = contentArea.querySelector('#tl-banca');
  if (bancaEl) {
    const bancaCombo = new Combobox(bancaEl, {
      placeholder: 'Selecteaz\u0103 banca...',
      readonly: true,
      staticData: manager.pendingComboData.get('tl-banca') || [],
      onSelect: (value, text) => {
        eventBus.emit(EVENTS.USER_ACTIVITY);
        manager.formData.IdBanca = value;
        manager.formData.Banca = text;

        // Actualizeaza codul bancii (foloseste value ca cod implicit)
        const codInput = contentArea.querySelector('#tl-cod-banca');
        if (codInput) codInput.value = value || '';

        // Triggereaza reload consilieri pentru banca selectata
        const consilierCombo = manager.components.bancar?.get('tl-consilier-banca');
        if (consilierCombo) {
          consilierCombo.options.staticData = [];
          consilierCombo.clear();
        }
        if (value) {
          eventBus.emit(EVENTS.EXTRA_DATA_LOAD_START, {
            requestId: `tl-consilieri-${value}`,
            endpoint: '/api/transfer-lead/consilieri-banca',
            requestType: 'tl_consilieri_banca',
            params: { id_banca: value },
          });
        }

        manager.isDirty = true;
        const saveBtn = manager.panelElement.querySelector('#tl-btn-save');
        if (saveBtn) saveBtn.disabled = false;
      },
    });

    if (manager.pendingComboData.has('tl-banca')) {
      bancaCombo.options.staticData = manager.pendingComboData.get('tl-banca');
      manager.pendingComboData.delete('tl-banca');
    }

    manager.components.bancar.set('tl-banca', bancaCombo);
  }

  // Combobox Consilier Banca (dependent de banca)
  const consilierEl = contentArea.querySelector('#tl-consilier-banca');
  if (consilierEl) {
    const consilierCombo = new Combobox(consilierEl, {
      placeholder: 'Selecteaz\u0103 consilier...',
      readonly: true,
      staticData: [],
      onSelect: (value, text) => {
        eventBus.emit(EVENTS.USER_ACTIVITY);
        manager.formData.IdConsilier = value;
        manager.formData.Consilier = text;
        manager.isDirty = true;
        const saveBtn = manager.panelElement.querySelector('#tl-btn-save');
        if (saveBtn) saveBtn.disabled = false;
      },
    });
    manager.components.bancar.set('tl-consilier-banca', consilierCombo);
  }

  // Combobox Evaluator
  const evaluatorEl = contentArea.querySelector('#tl-evaluator');
  if (evaluatorEl) {
    const evaluatorCombo = new Combobox(evaluatorEl, {
      placeholder: 'Selecteaz\u0103 evaluator...',
      readonly: true,
      staticData: manager.pendingComboData.get('tl-evaluator') || [],
      onSelect: (value, text) => {
        eventBus.emit(EVENTS.USER_ACTIVITY);
        manager.formData.IdEvaluator = value;
        manager.formData.Evaluator = text;
        manager.isDirty = true;
        const saveBtn = manager.panelElement.querySelector('#tl-btn-save');
        if (saveBtn) saveBtn.disabled = false;
      },
    });

    if (manager.pendingComboData.has('tl-evaluator')) {
      evaluatorCombo.options.staticData = manager.pendingComboData.get('tl-evaluator');
      manager.pendingComboData.delete('tl-evaluator');
    }

    manager.components.bancar.set('tl-evaluator', evaluatorCombo);
  }

  // Combobox Notar
  const notarEl = contentArea.querySelector('#tl-notar');
  if (notarEl) {
    const notarCombo = new Combobox(notarEl, {
      placeholder: 'Selecteaz\u0103 notar...',
      readonly: true,
      staticData: manager.pendingComboData.get('tl-notar') || [],
      onSelect: (value, text) => {
        eventBus.emit(EVENTS.USER_ACTIVITY);
        manager.formData.IdNotar = value;
        manager.formData.Notar = text;
        manager.isDirty = true;
        const saveBtn = manager.panelElement.querySelector('#tl-btn-save');
        if (saveBtn) saveBtn.disabled = false;
      },
    });

    if (manager.pendingComboData.has('tl-notar')) {
      notarCombo.options.staticData = manager.pendingComboData.get('tl-notar');
      manager.pendingComboData.delete('tl-notar');
    }

    manager.components.bancar.set('tl-notar', notarCombo);
  }

  manager.bancarComponentsInit = true;
}

export const BANCAR_TAB_CONFIG = {
  id: 'bancar',
  label: 'BANCAR',
  icon: '\ud83c\udfe6',
  order: 2,
  buildContent: buildBancarContent,
  onActivate: activateBancar,
  onDeactivate: () => {},
};
