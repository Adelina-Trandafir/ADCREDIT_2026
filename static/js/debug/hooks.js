(function () {
  const MIN_ZINDEX = 1000;

  // Funcție internă de log
  function log(message, type = 'log') {
    const now = new Date();
    const ts = `${now.toLocaleTimeString('en-GB', { hour12: false })}.${now
      .getMilliseconds()
      .toString()
      .padStart(3, '0')}`;
    const CPN = 'ZINDEX-HOOK'.padEnd(15);
    const style =
      type === 'error'
        ? 'color: #ef4444; font-weight: bold;'
        : 'color: #77ff87ff; font-weight: bold;';
    if (type === 'error') console.error(`%c[${ts}] [${CPN}] ${message}`, style);
    else console.log(`%c[${ts}] [${CPN}] ${message}`, style);
  }

  // Helper pentru descriere element
  function describeElement(el) {
    const tag = el.tagName.toLowerCase();
    const id = el.id ? `#${el.id}` : '';
    const classes = el.className ? `.${el.className.split(' ').join('.')}` : '';
    return `${tag}${id}${classes}`;
  }

  // Helper pentru outerHTML scurt
  function shortOuterHTML(el, maxLen = 80) {
    let html = el.outerHTML.replace(/\s+/g, ' ');
    if (html.length > maxLen) html = html.slice(0, maxLen) + '…';
    return html;
  }

  // =========================
  // 1️⃣ Override pentru setProperty / .style.zIndex
  // =========================
  const originalSetProperty = CSSStyleDeclaration.prototype.setProperty;
  CSSStyleDeclaration.prototype.setProperty = function (prop, value, priority) {
    if (prop === 'z-index') {
      log(`🔎 z-index set on element ${describeElement(this.ownerElement || this)} → ${value}`);

      // ⚠️ Linia care ar schimba efectiv z-index
      // if (parseInt(value, 10) < MIN_ZINDEX) value = MIN_ZINDEX.toString();
    }
    return originalSetProperty.call(this, prop, value, priority);
  };

  // =========================
  // 2️⃣ MutationObserver pentru class/style changes
  // =========================
  const observer = new MutationObserver((mutations) => {
    mutations.forEach((m) => {
      if (m.type === 'attributes' && (m.attributeName === 'style' || m.attributeName === 'class')) {
        const el = m.target;
        const z = window.getComputedStyle(el).zIndex;
        //if (!isNaN(z) && parseInt(z, 10) < MIN_ZINDEX) {
        //log(`z-index pe element ${describeElement(el)} (${shortOuterHTML(el)} → ${z})`);
        log(`z-index pe element ${describeElement(el)} → ${z}`);
        // ⚠️ Linia care ar corecta z-index-ul
        // el.style.zIndex = MIN_ZINDEX;
        //}
      }
    });
  });

  observer.observe(document.body, {
    attributes: true,
    subtree: true,
    attributeFilter: ['style', 'class'],
  });

  log('✅ Z-index hook inițializat și activ pentru inline și class/style changes');
})();
