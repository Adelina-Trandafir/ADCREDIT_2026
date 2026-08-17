/**
 * TRANSFER LEAD - TAB DOSAR
 * Placeholder - implementare viitoare.
 */

export const DOSAR_TAB_CONFIG = {
  id: 'dosar',
  label: 'DOSAR',
  icon: '\ud83d\udcc1',
  order: 3,
  buildContent: async () => {
    const div = document.createElement('div');
    div.className = 'tl-tab-placeholder';
    div.innerHTML = '<p>Sec\u021biunea DOSAR - \u00een curs de implementare</p>';
    return div;
  },
  onActivate: async () => {},
  onDeactivate: () => {},
};
