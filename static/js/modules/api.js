// js/modules/api.js
// toate apelurile HTTP
export const API = {
  async getColumns(tab) {
    const res = await fetch(`/api/column-settings?tab=${tab}`);
    if (!res.ok) throw new Error(res.statusText);
    return res.json();
  },

  async saveColumns(tab, columns) {
    const res = await fetch('/api/manage_column_settings', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ action: 'update', selTab: tab, columns }),
    });
    if (!res.ok) throw new Error(res.statusText);
    return res.json();
  },

  async resetColumns(tab) {
    const res = await fetch('/api/manage_column_settings', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ action: 'reset', selTab: tab }),
    });
    if (!res.ok) throw new Error(res.statusText);
    return res.json();
  },
};
