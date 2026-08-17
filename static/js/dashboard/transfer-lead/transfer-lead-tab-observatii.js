/**
 * TRANSFER LEAD - TAB OBSERVATII
 * Placeholder - implementare viitoare.
 */

export const OBSERVATII_TAB_CONFIG = {
  id: 'observatii',
  label: 'OBSERVA\u021aII',
  icon: '\ud83d\udcdd',
  order: 4,
  buildContent: async () => {
    const div = document.createElement('div');
    div.className = 'tl-tab-placeholder';
    div.innerHTML = '<p>Sec\u021biunea OBSERVA\u021aII - \u00een curs de implementare</p>';
    return div;
  },
  onActivate: async () => {},
  onDeactivate: () => {},
};
