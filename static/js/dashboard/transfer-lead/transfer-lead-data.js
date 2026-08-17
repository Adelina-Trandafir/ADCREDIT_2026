/**
 * TRANSFER LEAD DATA
 * Incarca date statice via fetch direct catre endpoint-urile proprii.
 * Nu foloseste EXTRA_DATA_LOAD_START/COMPLETE deoarece proxy-ul central
 * (/api/get-extra-data) nu cunoaste endpoint-urile transfer-lead.
 */

/**
 * Initializeaza listenerii pentru date extra.
 * Pastrat pentru compatibilitate cu manager.init() - nu mai are corp.
 * @param {Object} _manager
 */
export function setupDataListeners(_manager) {
  // Date statice sunt incarcate direct in loadInitialData.
  // Rezultatele de search sunt gestionate inline in transfer-lead-form.js.
}

/**
 * Initiaza incarcarea datelor statice via fetch direct.
 * @param {Object} manager
 */
export async function loadInitialData(manager) {
  const staticRequests = [
    { endpoint: '/api/transfer-lead/domenii',     comboKey: 'tl-domeniu-container',  section: 'functia' },
    { endpoint: '/api/transfer-lead/tip-comp',    comboKey: 'tl-tip-comp-container', section: 'functia' },
    { endpoint: '/api/transfer-lead/tip-venit',   comboKey: 'tl-tip-venit',          section: 'financiar' },
    { endpoint: '/api/transfer-lead/tip-imobil',  comboKey: 'tl-tip-imobil',         section: 'financiar' },
    { endpoint: '/api/transfer-lead/tip-credit',  comboKey: 'tl-tip-credit',         section: 'financiar' },
    { endpoint: '/api/transfer-lead/monede',      comboKey: 'tl-moneda',             section: 'financiar' },
    { endpoint: '/api/transfer-lead/tip-dobanda', comboKey: 'tl-tip-dobanda',        section: 'financiar' },
    { endpoint: '/api/transfer-lead/banci',       comboKey: 'tl-banca',              section: 'bancar' },
    { endpoint: '/api/transfer-lead/evaluatori',  comboKey: 'tl-evaluator',          section: 'bancar' },
    { endpoint: '/api/transfer-lead/notari',      comboKey: 'tl-notar',              section: 'bancar' },
  ];

  await Promise.allSettled(
    staticRequests.map(async ({ endpoint, comboKey, section }) => {
      try {
        const resp = await fetch(endpoint);
        if (!resp.ok) return;
        const data = await resp.json();
        if (!data.success) return;
        const formatted = _formatResults(data.results || []);
        _applyComboData(manager, section, comboKey, formatted);
      } catch {
        // silent - date vor fi goale
      }
    })
  );
}

// ============================================================
// Utilitare private
// ============================================================

/**
 * Aplica datele formatate pe combobox-ul corespunzator.
 * Daca combobox-ul nu a fost inca creat, stocheaza in pendingComboData.
 */
function _applyComboData(manager, section, comboKey, formatted) {
  if (section === 'functia') {
    const combo = manager.components.functiaComponents?.get(comboKey);
    if (combo) {
      combo.options.staticData = formatted;
    } else {
      manager.pendingComboData.set(comboKey, formatted);
    }
  } else {
    const combo = manager.components[section]?.get(comboKey);
    if (combo) {
      combo.options.staticData = formatted;
    } else {
      manager.pendingComboData.set(comboKey, formatted);
    }
  }
}

function _formatResults(results) {
  if (!Array.isArray(results)) return [];
  return results.map((r) => ({
    value: r.value ?? r.id ?? r.IdBaza ?? '',
    text: r.text ?? r.denumire ?? r.Denumire ?? r.name ?? String(r.value ?? ''),
  }));
}
