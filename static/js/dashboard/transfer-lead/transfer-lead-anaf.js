/**
 * TRANSFER LEAD - ANAF SEARCH
 * Modal de cautare firma prin ANAF.
 * Se deschide deasupra panelului principal ca modal secundar.
 *
 * OVERLAY: gestionat 100% de overlayManager. NU se creeaza overlay manual.
 */

import overlayManager from '../../utils/overlay-manager.js';
import eventBus, { EVENTS } from '../../event-bus/event-bus.js';

// State local al modulului
let anafModal = null;
let currentManager = null;

/**
 * Initializeaza ascultarea evenimentelor ANAF.
 * @param {Object} manager
 */
export function initAnafSearch(manager) {
  manager.addBusListener(EVENTS.ANAF_SEARCH_OPEN, (data) => {
    openAnafModal(manager, data.data || data);
  });
}

/**
 * Deschide modalul de cautare ANAF.
 * @param {Object} manager
 * @param {Object} data - { query }
 */
export function openAnafModal(manager, data) {
  currentManager = manager;
  const query = data?.query || '';

  // Creeaza modalul o singura data
  if (!anafModal) {
    anafModal = document.createElement('div');
    anafModal.id = 'tl-anaf-modal';

    anafModal.innerHTML = `
      <div class="tl-anaf-header">
        <span>Caut\u0103 firm\u0103 ANAF</span>
        <button class="tl-anaf-close-btn" type="button" id="tl-anaf-close-btn" title="\u00cenchide">\u00d7</button>
      </div>
      <div class="tl-anaf-search-row">
        <input type="text" id="tl-anaf-input" placeholder="Denumire sau CUI firm\u0103..." />
        <button class="tl-anaf-search-btn" type="button" id="tl-anaf-search-btn">Caut\u0103</button>
      </div>
      <div id="tl-anaf-results"></div>
    `;

    document.body.appendChild(anafModal);
  }

  // Seteaza valoarea initiala din combobox
  const input = anafModal.querySelector('#tl-anaf-input');
  if (input) input.value = query;

  // Arata modalul
  anafModal.classList.add('tl-anaf-modal--visible');
  anafModal.style.display = 'flex';

  // Inregistreaza la overlayManager
  overlayManager.subscribe(manager, anafModal, {
    onClick: () => closeAnafModal(manager),
    onEscape: () => closeAnafModal(manager),
  });

  // Ataseaza listeneri DOM prin manager (pentru cleanup automat)
  const closeBtn = anafModal.querySelector('#tl-anaf-close-btn');
  if (closeBtn) {
    manager.addDOMListener(closeBtn, 'click', () => closeAnafModal(manager));
  }

  const searchBtn = anafModal.querySelector('#tl-anaf-search-btn');
  if (searchBtn) {
    manager.addDOMListener(searchBtn, 'click', () => {
      const q = anafModal.querySelector('#tl-anaf-input')?.value || '';
      searchAnaf(q, manager);
    });
  }

  if (input) {
    manager.addDOMListener(input, 'keydown', (e) => {
      if (e.key === 'Enter') {
        searchAnaf(input.value, manager);
      }
    });

    // Focus pe input
    setTimeout(() => input.focus(), 50);
  }

  // Daca exista un query initial, porneste cautarea
  if (query.length >= 3) {
    searchAnaf(query, manager);
  }
}

/**
 * Executa cautarea ANAF.
 * @param {string} query
 * @param {Object} manager
 */
async function searchAnaf(query, manager) {
  eventBus.emit(EVENTS.USER_ACTIVITY);

  const resultsDiv = anafModal?.querySelector('#tl-anaf-results');
  if (!resultsDiv) return;

  if (!query || query.trim().length < 2) {
    resultsDiv.innerHTML = '<div class="tl-anaf-empty">Introdu\u021bi minim 2 caractere pentru c\u0103utare.</div>';
    return;
  }

  resultsDiv.innerHTML = '<div class="tl-anaf-loading">\ud83d\udd0d C\u0103utare...</div>';

  try {
    const response = await fetch(`/api/anaf/search?q=${encodeURIComponent(query.trim())}`);
    const json = await response.json();

    if (!json.success) {
      resultsDiv.innerHTML = `<div class="tl-anaf-error">Eroare: ${json.error || 'Cerere e\u015buat\u0103'}</div>`;
      return;
    }

    const results = json.results || [];

    if (results.length === 0) {
      resultsDiv.innerHTML = '<div class="tl-anaf-empty">Nu s-au g\u0103sit firme pentru c\u0103utarea introdus\u0103.</div>';
      return;
    }

    resultsDiv.innerHTML = results
      .map(
        (r) => `
      <div class="tl-anaf-result-item"
           data-cui="${r.cui}"
           data-denumire="${r.denumire}">
        <strong>${r.denumire}</strong>
        <span style="color:#888;font-size:10px;margin-left:6px;">CUI: ${r.cui}</span>
      </div>
    `
      )
      .join('');

    // Click pe item
    resultsDiv.querySelectorAll('.tl-anaf-result-item').forEach((item) => {
      manager.addDOMListener(item, 'click', () => {
        selectAnafFirma(item.dataset.cui, item.dataset.denumire, manager);
      });
    });
  } catch (err) {
    resultsDiv.innerHTML = `<div class="tl-anaf-error">Eroare de re\u021bea. \u00cencerca\u021bi din nou.</div>`;
    manager.log.error('Eroare cautare ANAF', err);
  }
}

/**
 * Selecteaza o firma din rezultatele ANAF.
 * @param {string} cui
 * @param {string} denumire
 * @param {Object} manager
 */
function selectAnafFirma(cui, denumire, manager) {
  eventBus.emit(EVENTS.ANAF_SEARCH_SELECT, { cui, denumire });
  closeAnafModal(manager);
}

/**
 * Inchide modalul ANAF si dezinregistreaza de la overlayManager.
 * @param {Object} manager
 */
export function closeAnafModal(manager) {
  if (anafModal) {
    anafModal.classList.remove('tl-anaf-modal--visible');
    anafModal.style.display = 'none';

    // Curata rezultatele pentru urmatoarea deschidere
    const resultsDiv = anafModal.querySelector('#tl-anaf-results');
    if (resultsDiv) resultsDiv.innerHTML = '';
  }

  // Dezinregistreaza de la overlayManager
  overlayManager.unsubscribe(manager);

  eventBus.emit(EVENTS.ANAF_SEARCH_CLOSE);
}
