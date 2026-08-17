/**
 * TRANSFER LEAD STATE
 * Gestioneaza deschiderea, inchiderea, salvarea si anularea panelului.
 * Pattern identic cu details-panel-baza-ui.js.
 *
 * OVERLAY: gestionat 100% de overlayManager. NU se creeaza overlay manual.
 */

import overlayManager from '../../utils/overlay-manager.js';
import eventBus, { EVENTS } from '../../event-bus/event-bus.js';
import * as FormManager from './transfer-lead-form.js';
import * as TabManager from './transfer-lead-tabs.js';

/**
 * Deschide panelul Transfer Lead.
 * @param {Object} manager
 * @param {string|number} rowId
 * @param {Object} rowData
 */
export async function openPanel(manager, rowId, rowData) {
  if (manager.isVisible) {
    await closePanel(manager);
  }

  manager.currentRowId = rowId;
  manager.currentRowData = rowData;
  manager.stats.opens++;

  // Populeaza formularul cu datele randului
  FormManager.populateForm(manager, rowData);

  // Activeaza primul tab
  await TabManager.activateTab(manager, 'financiar');

  // Inregistreaza la overlayManager - seteaza automat z-index
  overlayManager.subscribe(manager, manager.panelElement, {
    onClick: () => {
      if (!manager.isDirty) closePanel(manager);
    },
    onEscape: () => {
      if (!manager.isDirty) closePanel(manager);
    },
  });

  // Arata panelul cu animatie CSS
  manager.panelElement.classList.remove('tl-panel--hidden');
  manager.panelElement.classList.add('tl-panel--visible');

  manager.isVisible = true;
  document.body.style.overflow = 'hidden';

  eventBus.emit(EVENTS.TRANSFER_LEAD_OPENED, {
    rowId,
    timestamp: Date.now(),
  });

  manager.log(`Panel deschis pentru rowId: ${rowId}`);
}

/**
 * Inchide panelul Transfer Lead.
 * @param {Object} manager
 * @returns {boolean} true daca s-a inchis, false daca utilizatorul a anulat
 */
export async function closePanel(manager) {
  if (manager.isDirty) {
    const confirmed = confirm(
      'Exist\u0103 modific\u0103ri nesalvate. Sigur \u00eenchizi?'
    );
    if (!confirmed) return false;
  }

  // Animatie disparitie
  manager.panelElement.classList.remove('tl-panel--visible');
  manager.panelElement.classList.add('tl-panel--hidden');

  // Dezinregistreaza de la overlayManager
  overlayManager.unsubscribe(manager);

  document.body.style.overflow = '';
  manager.isVisible = false;

  FormManager.clearForm(manager);

  const closedRowId = manager.currentRowId;
  manager.currentRowId = null;
  manager.currentRowData = null;
  manager.originalData = null;

  // Reset stare tab-uri (pentru urmatoarea deschidere)
  manager.builtTabs.clear();
  manager.financiarComponentsInit = false;
  manager.bancarComponentsInit = false;

  // Curata componente din tab-uri (vor fi recreate la urmatoarea deschidere)
  if (manager.components.financiar) manager.components.financiar.clear();
  if (manager.components.bancar) manager.components.bancar.clear();

  // Curata continutul tab-urilor din DOM
  const contentArea = manager.panelElement?.querySelector('#tl-tab-content-area');
  if (contentArea) contentArea.innerHTML = '';

  // Curata clasa activa de pe butoanele tab-urilor
  manager.panelElement?.querySelectorAll('.tl-tab-btn--active').forEach((btn) => {
    btn.classList.remove('tl-tab-btn--active');
  });

  manager.activeTabId = null;

  eventBus.emit(EVENTS.TRANSFER_LEAD_CLOSED, { rowId: closedRowId });
  manager.log(`Panel inchis, rowId: ${closedRowId}`);

  return true;
}

/**
 * Salveaza modificarile din formular.
 * @param {Object} manager
 * @returns {boolean}
 */
export async function saveChanges(manager) {
  // Validare minima
  if (!manager.formData.IdFunctie) {
    const errorBar = manager.panelElement.querySelector('#tl-save-error');
    if (errorBar) {
      errorBar.textContent = 'Func\u021bia este obligatorie!';
      errorBar.classList.add('tl-error-bar--visible');
      setTimeout(() => errorBar.classList.remove('tl-error-bar--visible'), 4000);
    }
    return false;
  }

  const saveBtn = manager.panelElement.querySelector('#tl-btn-save');
  if (saveBtn) {
    saveBtn.disabled = true;
    const saveBtnText = saveBtn.querySelector('.btn-text-span');
    if (saveBtnText) saveBtnText.textContent = 'Salvare...';
  }

  const data = FormManager.collectFormData(manager);
  const rowId = manager.currentRowId;

  eventBus.emit(EVENTS.TRANSFER_LEAD_SAVE_REQUEST, { rowId, data });

  try {
    const response = await fetch('/api/transfer-lead/save', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ rowId, ...data }),
    });

    const json = await response.json();

    if (!json.success) {
      throw new Error(json.error || 'Eroare necunoscut\u0103');
    }

    manager.stats.saves++;
    eventBus.emit(EVENTS.TRANSFER_LEAD_SAVED, { rowId, data });
    manager.log('Salvat cu succes');

    await closePanel(manager);
    return true;
  } catch (err) {
    manager.log.error('Eroare salvare', err);

    const errorBar = manager.panelElement.querySelector('#tl-save-error');
    if (errorBar) {
      errorBar.textContent = `Eroare: ${err.message}`;
      errorBar.classList.add('tl-error-bar--visible');
    }

    if (saveBtn) {
      saveBtn.disabled = false;
      const saveBtnText = saveBtn.querySelector('.btn-text-span');
      if (saveBtnText) saveBtnText.textContent = 'Salveaz\u0103';
    }

    eventBus.emit(EVENTS.TRANSFER_LEAD_ERROR, { rowId, error: err.message });
    return false;
  }
}

/**
 * Anuleaza modificarile (echivalent cu inchidere).
 * @param {Object} manager
 */
export async function cancelChanges(manager) {
  manager.stats.cancels++;
  return closePanel(manager);
}
