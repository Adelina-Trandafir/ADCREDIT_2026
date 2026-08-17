/**
 * TRANSFER LEAD DOM BUILDER
 * Construieste structura HTML a panelului principal.
 * NU contine logica - doar structura DOM.
 *
 * Layout: drawer full-width ancorat in partea de jos a ecranului.
 * Sectiunile CLIENT | DETALII DOSAR | FUNCTIA sunt afisate una langa alta.
 * Butoanele Renunta / Salveaza sunt in footer-ul de jos (identic cu detailsPanelBaza).
 */

/**
 * Construieste elementul DOM principal al panelului Transfer Lead.
 * @param {Object} manager - instanta TransferLeadManager
 * @returns {HTMLElement} panelul creat
 */
export function buildPanelElement(_manager) {
  const panel = document.createElement('div');
  panel.id = 'tl-panel';
  panel.className = 'tl-panel tl-panel--hidden';

  panel.innerHTML = `
    <!-- HEADER -->
    <div class="tl-header">
      <span class="tl-header-title" id="tl-header-title">Transfer\u0103 simulare \u00een Dosare...</span>
    </div>

    <!-- BODY: CLIENT | DETALII DOSAR | FUNC\u021aIA | TABS - pe o singura linie -->
    <div class="tl-body">

      <!-- SECTIUNEA CLIENT -->
      <div class="tl-section" data-section="client">
        <div class="tl-section-header">CLIENT</div>
        <div class="tl-section-body">
          <div class="tl-field">
            <label for="tl-nume-client">Nume</label>
            <input type="text" id="tl-nume-client" readonly placeholder="" />
          </div>
          <div class="tl-field">
            <label for="tl-cnp">CNP</label>
            <span class="tl-ro-flag">\ud83c\uddf7\ud83c\uddf4</span>
            <input type="text" id="tl-cnp" readonly placeholder="" />
          </div>
          <div class="tl-field">
            <label for="tl-telefon">Telefon</label>
            <input type="text" id="tl-telefon" readonly placeholder="" />
          </div>
          <div class="tl-field">
            <label for="tl-email">E-Mail</label>
            <input type="text" id="tl-email" readonly placeholder="" />
          </div>
          <div class="tl-field">
            <label>Codebitor</label>
            <button id="tl-btn-codebitor" type="button">&lt; ADAUG\u0102 CODEBITOR &gt;</button>
          </div>
        </div>
      </div>

      <!-- SECTIUNEA DETALII DOSAR -->
      <div class="tl-section" data-section="detalii">
        <div class="tl-section-header">DETALII DOSAR</div>
        <div class="tl-section-body">
          <div class="tl-field">
            <label for="tl-data-introducere">Data</label>
            <input type="text" id="tl-data-introducere" readonly placeholder="" />
          </div>
          <div class="tl-field">
            <label for="tl-consultant">Consultant</label>
            <input type="text" id="tl-consultant" readonly placeholder="" />
          </div>
          <div class="tl-field">
            <label>Surs\u0103</label>
            <div id="tl-sursa-container" style="flex:1;min-width:0;"></div>
          </div>
        </div>
      </div>

      <!-- SECTIUNEA FUNC\u021aIA -->
      <div class="tl-section" data-section="functia">
        <div class="tl-section-header">FUNC\u021aIA</div>
        <div class="tl-section-body">
          <div class="tl-field">
            <label>Func\u021bie</label>
            <div id="tl-functie-container" style="flex:1;min-width:0;"></div>
          </div>
          <div class="tl-field">
            <label>Domeniu</label>
            <div id="tl-domeniu-container" style="flex:1;min-width:0;"></div>
          </div>
          <div class="tl-field">
            <label>Companie</label>
            <div id="tl-companie-container" style="flex:1;min-width:0;"></div>
          </div>
          <div class="tl-field">
            <label>Tip Comp.</label>
            <div id="tl-tip-comp-container" style="flex:1;min-width:0;"></div>
          </div>
        </div>
      </div>

      <!-- AREA TABS: tab bar vertical + continut tab -->
      <div class="tl-tabs-area">
        <div class="tl-tab-bar" id="tl-tab-bar">
          <!-- Butoanele tab-urilor construite dinamic de transfer-lead-tabs.js -->
        </div>
        <div class="tl-tab-content-area" id="tl-tab-content-area">
          <!-- Continutul tab-ului activ injectat dinamic -->
        </div>
      </div>

    </div>
    <!-- /BODY -->

    <!-- ERROR BAR -->
    <div class="tl-error-bar" id="tl-save-error"></div>

    <!-- FOOTER: butoane Renun\u0163\u0103 / Salveaz\u0103 (identic cu detailsPanelBaza) -->
    <div class="tl-panel-bottom">
      <button id="tl-btn-renunta" class="btn btn-secondary" type="button">
        <span class="btn-icon-span">\u274c</span>
        <span class="btn-text-span">Renun\u0163\u0103</span>
      </button>
      <button id="tl-btn-save" class="btn btn-primary" type="button" disabled>
        <span class="btn-text-span">Salveaz\u0103</span>
        <span class="btn-icon-span">\ud83d\udcbe</span>
      </button>
    </div>
  `;

  document.body.appendChild(panel);
  return panel;
}
