/**
 * TRANSFER LEAD FORM
 * Instantiaza si configureaza toate componentele interactive.
 * Gestioneaza sectiunile CLIENT (readonly), DETALII DOSAR (readonly) si FUNCTIA (editabile).
 */

import eventBus, { EVENTS } from '../../event-bus/event-bus.js';
import { Combobox } from '../../components/combobox/combobox.js';

/**
 * Initializeaza toate componentele interactive ale formularului.
 * @param {Object} manager
 */
export function setupFormComponents(manager) {
  _setupClientSection(manager);
  _setupDetaliiSection(manager);
  _setupFunctiaSection(manager);
}

/**
 * Sectiunea CLIENT - input-uri readonly
 * @param {Object} manager
 */
function _setupClientSection(manager) {
  const fieldIds = ['tl-nume-client', 'tl-cnp', 'tl-telefon', 'tl-email'];

  fieldIds.forEach((id) => {
    const el = manager.panelElement.querySelector(`#${id}`);
    if (el) {
      el.readOnly = true;
      manager.components.clientInputs.set(id, el);
    }
  });
}

/**
 * Sectiunea DETALII DOSAR - input-uri readonly + combobox sursa readonly
 * @param {Object} manager
 */
function _setupDetaliiSection(manager) {
  ['tl-data-introducere', 'tl-consultant'].forEach((id) => {
    const el = manager.panelElement.querySelector(`#${id}`);
    if (el) {
      el.readOnly = true;
      manager.components.dosarInputs.set(id, el);
    }
  });

  // Combobox Sursa - readonly
  const sursaEl = manager.panelElement.querySelector('#tl-sursa-container');
  if (sursaEl) {
    const sursaCombo = new Combobox(sursaEl, {
      placeholder: 'Surs\u0103...',
      readonly: true,
      staticData: [],
    });
    manager.components.dosarInputs.set('tl-sursa-container', sursaCombo);
  }
}

/**
 * Sectiunea FUNCTIA - combobox-uri editabile
 * @param {Object} manager
 */
function _setupFunctiaSection(manager) {
  // Combobox Functie - search direct fetch
  const functieEl = manager.panelElement.querySelector('#tl-functie-container');
  if (functieEl) {
    const functieCombo = new Combobox(functieEl, {
      placeholder: 'Selecteaz\u0103 func\u021bie...',
      searchDelay: 300,
      minSearchLength: 2,
      onSearch: async (query) => {
        eventBus.emit(EVENTS.USER_ACTIVITY);
        try {
          const resp = await fetch(`/api/transfer-lead/functii?q=${encodeURIComponent(query)}`);
          if (!resp.ok) return;
          const data = await resp.json();
          if (!data.success) return;
          const results = _fmt(data.results || []);
          const combo = manager.components.functiaComponents?.get('tl-functie-container');
          if (combo) {
            combo.updateResults(results, query);
            combo.renderResults(query);
            if (results.length > 0) combo.show();
          }
        } catch { /* silent */ }
      },
      onSelect: (value, text) => {
        eventBus.emit(EVENTS.USER_ACTIVITY);
        manager.formData.IdFunctie = value;
        manager.formData.Functie = text;
        markDirty(manager);
      },
    });
    manager.components.functiaComponents.set('tl-functie-container', functieCombo);
  }

  // Combobox Domeniu - static readonly
  const domeniuEl = manager.panelElement.querySelector('#tl-domeniu-container');
  if (domeniuEl) {
    const domeniuCombo = new Combobox(domeniuEl, {
      placeholder: 'Selecteaz\u0103 domeniu...',
      readonly: true,
      staticData: manager.pendingComboData.get('tl-domeniu-container') || [],
      onSelect: (value, text) => {
        eventBus.emit(EVENTS.USER_ACTIVITY);
        manager.formData.IdDomeniu = value;
        manager.formData.Domeniu = text;
        markDirty(manager);
      },
    });

    if (manager.pendingComboData.has('tl-domeniu-container')) {
      domeniuCombo.options.staticData = manager.pendingComboData.get('tl-domeniu-container');
      manager.pendingComboData.delete('tl-domeniu-container');
    }

    manager.components.functiaComponents.set('tl-domeniu-container', domeniuCombo);
  }

  // Combobox Companie - search direct fetch cu optiune ANAF
  const companieEl = manager.panelElement.querySelector('#tl-companie-container');
  if (companieEl) {
    let lastCompanieQuery = '';
    const companieCombo = new Combobox(companieEl, {
      placeholder: 'Caut\u0103 companie...',
      searchDelay: 400,
      minSearchLength: 3,
      onSearch: async (query) => {
        eventBus.emit(EVENTS.USER_ACTIVITY);
        lastCompanieQuery = query;
        try {
          const resp = await fetch(`/api/transfer-lead/companii?q=${encodeURIComponent(query)}`);
          if (!resp.ok) return;
          const data = await resp.json();
          if (!data.success) return;
          let results = _fmt(data.results || []);
          const combo = manager.components.functiaComponents?.get('tl-companie-container');
          if (!combo) return;
          if (results.length === 0) {
            results = [{ value: '__anaf__', text: `\ud83d\udd0d Caut\u0103 firma ANAF: "${query}"` }];
          }
          combo.updateResults(results, query);
          combo.renderResults(query);
          combo.show();
        } catch { /* silent */ }
      },
      onSelect: (value, text) => {
        eventBus.emit(EVENTS.USER_ACTIVITY);
        if (value === '__anaf__') {
          eventBus.emit(EVENTS.ANAF_SEARCH_OPEN, { query: lastCompanieQuery });
          return;
        }
        manager.formData.CUI = value;
        manager.formData.Companie = text;
        markDirty(manager);
      },
    });
    manager.components.functiaComponents.set('tl-companie-container', companieCombo);
  }

  // Combobox Tip Companie - static readonly
  const tipCompEl = manager.panelElement.querySelector('#tl-tip-comp-container');
  if (tipCompEl) {
    const tipCompCombo = new Combobox(tipCompEl, {
      placeholder: 'Tip companie...',
      readonly: true,
      staticData: manager.pendingComboData.get('tl-tip-comp-container') || [],
      onSelect: (value, text) => {
        eventBus.emit(EVENTS.USER_ACTIVITY);
        manager.formData.IdTipComp = value;
        manager.formData.TipComp = text;
        markDirty(manager);
      },
    });

    if (manager.pendingComboData.has('tl-tip-comp-container')) {
      tipCompCombo.options.staticData = manager.pendingComboData.get('tl-tip-comp-container');
      manager.pendingComboData.delete('tl-tip-comp-container');
    }

    manager.components.functiaComponents.set('tl-tip-comp-container', tipCompCombo);
  }
}

/**
 * Populeaza formularul cu datele din randul selectat.
 * @param {Object} manager
 * @param {Object} rowData
 */
export function populateForm(manager, rowData) {
  if (!rowData) return;

  // Sectiunea CLIENT
  _setInput(manager, 'tl-nume-client', rowData.NumeClient || '');
  _setInput(manager, 'tl-cnp', rowData.CNPClient || '');
  _setInput(manager, 'tl-telefon', rowData.TelefonClient || '');
  _setInput(manager, 'tl-email', rowData.EmailClient || '');

  // Sectiunea DETALII DOSAR
  const dataStr = rowData.DataPrimire
    ? _formatDateRO(rowData.DataPrimire)
    : '';
  _setInput(manager, 'tl-data-introducere', dataStr);
  _setInput(manager, 'tl-consultant', rowData.NumeConsultant || '');

  // Sursa - combobox readonly
  const sursaCombo = manager.components.dosarInputs.get('tl-sursa-container');
  if (sursaCombo && rowData.IdSursa) {
    sursaCombo.setValue(rowData.IdSursa, rowData.Sursa || String(rowData.IdSursa));
  }

  // Titlu header
  const titleEl = manager.panelElement.querySelector('#tl-header-title');
  if (titleEl) {
    const client = rowData.NumeClient || 'Client necunoscut';
    const consultant = rowData.NumeConsultant || '';
    titleEl.textContent = `Transfer\u0103 simul\u0103re \u00een Dosare pentru ${client}${consultant ? ` prelucrat de ${consultant}` : ''}`;
    titleEl.title = titleEl.textContent;
  }

  // Salveaza datele originale
  manager.originalData = { ...rowData };
  manager.formData = {};
}

/**
 * Colecteaza toate datele din formular (pentru save).
 * @param {Object} manager
 * @returns {Object}
 */
export function collectFormData(manager) {
  const data = { ...manager.formData };

  // Adauga date din tab-ul activ daca sunt disponibile
  if (manager.activeTabId === 'financiar') {
    const contentArea = manager.panelElement.querySelector('[data-tab-content="financiar"]');
    if (contentArea) {
      data.ValVenit = contentArea.querySelector('#tl-val-venit')?.value || '';
      data.ValImobil = contentArea.querySelector('#tl-val-imobil')?.value || '';
      data.ValCredit = contentArea.querySelector('#tl-val-credit')?.value || '';
      data.Perioada = contentArea.querySelector('#tl-perioada')?.value || '';
      data.AreImobil = contentArea.querySelector('#tl-are-imobil')?.checked ? 1 : 0;

      // Valori din combobox-uri financiare
      const financiarCombos = ['tl-tip-venit', 'tl-tip-imobil', 'tl-tip-credit', 'tl-moneda', 'tl-tip-dobanda'];
      financiarCombos.forEach((id) => {
        const combo = manager.components.financiar?.get(id);
        if (combo) {
          data[id.replace('tl-', '').replace(/-/g, '_')] = combo.getSelectedValue() || '';
        }
      });
    }
  }

  if (manager.activeTabId === 'bancar') {
    // Valori din combobox-uri bancare
    const bancarCombos = ['tl-banca', 'tl-consilier-banca', 'tl-evaluator', 'tl-notar'];
    bancarCombos.forEach((id) => {
      const combo = manager.components.bancar?.get(id);
      if (combo) {
        data[id.replace('tl-', '').replace(/-/g, '_')] = combo.getSelectedValue() || '';
      }
    });
  }

  return data;
}

/**
 * Marcheaza formularul ca modificat si activeaza butonul Save.
 * @param {Object} manager
 */
export function markDirty(manager) {
  manager.isDirty = true;
  const saveBtn = manager.panelElement?.querySelector('#tl-btn-save');
  if (saveBtn) saveBtn.disabled = false;
}

/**
 * Reseteaza toate campurile editabile la starea initiala.
 * @param {Object} manager
 */
export function clearForm(manager) {
  // Reset combobox-uri din FUNCTIA
  ['tl-functie-container', 'tl-domeniu-container', 'tl-companie-container', 'tl-tip-comp-container'].forEach((id) => {
    const combo = manager.components.functiaComponents.get(id);
    if (combo) combo.clear();
  });

  // Reset input-uri client si dosar
  ['tl-nume-client', 'tl-cnp', 'tl-telefon', 'tl-email', 'tl-data-introducere', 'tl-consultant'].forEach((id) => {
    const el = manager.panelElement?.querySelector(`#${id}`);
    if (el) el.value = '';
  });

  // Reset sursa combobox
  const sursaCombo = manager.components.dosarInputs.get('tl-sursa-container');
  if (sursaCombo) sursaCombo.clear();

  // Reset titlu header
  const titleEl = manager.panelElement?.querySelector('#tl-header-title');
  if (titleEl) titleEl.textContent = 'Transfer\u0103 simul\u0103re \u00een Dosare...';

  // Reset error bar
  const errorBar = manager.panelElement?.querySelector('#tl-save-error');
  if (errorBar) {
    errorBar.textContent = '';
    errorBar.classList.remove('tl-error-bar--visible');
  }

  // Reset buton Save
  const saveBtn = manager.panelElement?.querySelector('#tl-btn-save');
  if (saveBtn) saveBtn.disabled = true;

  manager.formData = {};
  manager.isDirty = false;
}

// ============================================================
// Utilitare private
// ============================================================

function _fmt(results) {
  if (!Array.isArray(results)) return [];
  return results.map((r) => ({
    value: r.value ?? r.id ?? '',
    text: r.text ?? r.denumire ?? r.Denumire ?? String(r.value ?? ''),
  }));
}

function _setInput(manager, id, value) {
  const el = manager.panelElement?.querySelector(`#${id}`);
  if (el) el.value = value;
}

function _formatDateRO(dateStr) {
  if (!dateStr) return '';
  try {
    const d = new Date(dateStr);
    if (isNaN(d.getTime())) return dateStr;
    const dd = String(d.getDate()).padStart(2, '0');
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const yyyy = d.getFullYear();
    const hh = String(d.getHours()).padStart(2, '0');
    const min = String(d.getMinutes()).padStart(2, '0');
    return `${dd}/${mm}/${yyyy} ${hh}:${min}`;
  } catch {
    return dateStr;
  }
}
