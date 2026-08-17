/**
 * TRANSFER LEAD TABS
 * Sistem modular de tab-uri verticale (emuleaza TabControl din Access).
 * Extensibil - se adauga tab-uri noi fara modificari in acest fisier.
 */

import eventBus, { EVENTS } from '../../event-bus/event-bus.js';

/**
 * Inregistreaza un tab in registry-ul managerului.
 * @param {Object} manager
 * @param {Object} tabConfig - { id, label, icon, order, buildContent, onActivate, onDeactivate }
 */
export function registerTab(manager, tabConfig) {
  manager.tabRegistry.set(tabConfig.id, tabConfig);
}

/**
 * Construieste bara de tab-uri si activeaza primul tab.
 * @param {Object} manager
 */
export function initTabs(manager) {
  const tabBar = manager.panelElement.querySelector('#tl-tab-bar');
  if (!tabBar) return;

  tabBar.innerHTML = '';

  // Sorteaza tab-urile dupa proprietatea order
  const sortedTabs = [...manager.tabRegistry.values()].sort((a, b) => a.order - b.order);

  sortedTabs.forEach((tab) => {
    const btn = document.createElement('button');
    btn.className = 'tl-tab-btn';
    btn.dataset.tabId = tab.id;
    btn.type = 'button';
    btn.textContent = (tab.icon ? tab.icon + ' ' : '') + tab.label;
    btn.title = tab.label;

    manager.addDOMListener(btn, 'click', () => {
      activateTab(manager, tab.id);
    });

    tabBar.appendChild(btn);
  });

  // Activeaza primul tab
  if (sortedTabs.length > 0) {
    activateTab(manager, sortedTabs[0].id);
  }
}

/**
 * Activeaza un tab dupa ID.
 * @param {Object} manager
 * @param {string} tabId
 */
export async function activateTab(manager, tabId) {
  const newTab = manager.tabRegistry.get(tabId);
  if (!newTab) return;

  const contentArea = manager.panelElement.querySelector('#tl-tab-content-area');
  const tabBar = manager.panelElement.querySelector('#tl-tab-bar');
  if (!contentArea || !tabBar) return;

  // Dezactiveaza tab-ul curent
  if (manager.activeTabId && manager.activeTabId !== tabId) {
    const currentTab = manager.tabRegistry.get(manager.activeTabId);
    if (currentTab?.onDeactivate) {
      currentTab.onDeactivate(manager);
    }

    // Ascunde continutul curent
    const currentContent = contentArea.querySelector(`[data-tab-content="${manager.activeTabId}"]`);
    if (currentContent) {
      currentContent.hidden = true;
    }

    // Dezactiveaza butonul curent
    const currentBtn = tabBar.querySelector(`[data-tab-id="${manager.activeTabId}"]`);
    if (currentBtn) {
      currentBtn.classList.remove('tl-tab-btn--active');
    }
  }

  // Seteaza noul tab activ
  manager.activeTabId = tabId;

  // Activeaza butonul noului tab
  const newBtn = tabBar.querySelector(`[data-tab-id="${tabId}"]`);
  if (newBtn) {
    newBtn.classList.add('tl-tab-btn--active');
  }

  // Construieste sau arata continutul
  if (!manager.builtTabs.has(tabId)) {
    // Primul acces - construieste continutul
    const content = await newTab.buildContent(manager);
    content.setAttribute('data-tab-content', tabId);
    contentArea.appendChild(content);
    manager.builtTabs.add(tabId);
  } else {
    // Arata continutul deja construit
    const existingContent = contentArea.querySelector(`[data-tab-content="${tabId}"]`);
    if (existingContent) {
      existingContent.hidden = false;
    }
  }

  // Apeleaza onActivate
  if (newTab.onActivate) {
    await newTab.onActivate(manager);
  }

  eventBus.emit(EVENTS.TRANSFER_LEAD_TAB_CHANGED, { tabId });
}

/**
 * Returneaza ID-ul tab-ului activ curent.
 * @param {Object} manager
 * @returns {string|null}
 */
export function getActiveTabId(manager) {
  return manager.activeTabId;
}

/**
 * Curata bara de tab-uri si registry.
 * @param {Object} manager
 */
export function destroyTabs(manager) {
  const tabBar = manager.panelElement?.querySelector('#tl-tab-bar');
  if (tabBar) tabBar.innerHTML = '';

  const contentArea = manager.panelElement?.querySelector('#tl-tab-content-area');
  if (contentArea) contentArea.innerHTML = '';

  manager.tabRegistry.clear();
  manager.builtTabs.clear();
  manager.activeTabId = null;
}
