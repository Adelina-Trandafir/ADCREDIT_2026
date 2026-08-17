/**
 * TRANSFER LEAD - TAB EXTRA / ALTELE
 * Placeholder - implementare viitoare.
 */

export const EXTRA_TAB_CONFIG = {
  id: 'extra',
  label: 'ALTELE',
  icon: '\u2699\ufe0f',
  order: 5,
  buildContent: async () => {
    const div = document.createElement('div');
    div.className = 'tl-tab-placeholder';
    div.innerHTML = '<p>Sec\u021biunea ALTELE - \u00een curs de implementare</p>';
    return div;
  },
  onActivate: async () => {},
  onDeactivate: () => {},
};
