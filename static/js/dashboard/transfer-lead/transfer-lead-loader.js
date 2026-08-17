/**
 * TRANSFER LEAD LOADER
 * Incarca stylesheet-ul CSS pentru panel.
 * Template HTML este omis - DOM construit complet in JS (transfer-lead-dom.js)
 */

/**
 * Incarca stylesheet-ul transfer_lead.css
 * @param {Object} manager - instanta TransferLeadManager
 */
export async function loadTransferLeadStyles(manager) {
  const LINK_ID = 'transferLeadStyles';

  if (document.getElementById(LINK_ID)) {
    manager.log('Stiluri deja incarcate');
    return;
  }

  return new Promise((resolve, reject) => {
    const link = document.createElement('link');
    link.id = LINK_ID;
    link.rel = 'stylesheet';
    link.href = '/static/css/transfer_lead.css';

    link.onload = () => {
      manager.log('Stiluri incarcate cu succes');
      resolve();
    };

    link.onerror = (err) => {
      manager.log.error('Eroare la incarcarea stilurilor', err);
      reject(err);
    };

    document.head.appendChild(link);
  });
}

/**
 * Template HTML omis - DOM construit in transfer-lead-dom.js
 * Functie stub pastrata pentru compatibilitate cu pattern-ul din spec.
 * @returns {null}
 */
export async function loadTransferLeadTemplate(manager) {
  manager.log('Template HTML omis - DOM construit in JS');
  return null;
}
