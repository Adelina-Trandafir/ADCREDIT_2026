export const UtilsMixin = {
  /**
   * Formatează data în format românesc
   * @param {string} dateStr - Data de formatat
   * @returns {string} Data formatată sau '-' dacă lipsește
   */
  formatDate(dateStr) {
    if (!dateStr) return '-';
    const date = new Date(dateStr);
    return date.toLocaleDateString('ro-RO');
  },

  /**
   * Trunchiază textul la o lungime maximă
   * @param {string} text - Textul de trunchiat
   * @param {number} maxLength - Lungimea maximă
   * @returns {string} Textul trunchiat cu '...'
   */
  truncateText(text, maxLength) {
    if (!text) return '';
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
  },

  /**
   * Escape HTML pentru siguranță
   * @param {string} text - Textul de escape-uit
   * @returns {string} Textul cu caractere HTML escape-uite
   */
  escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  },

  /**
   * Returnează iconița corespunzătoare pentru nivelul consultantului
   * @param {number} idNivel - ID-ul nivelului consultantului
   * @returns {string} Iconița emoji corespunzătoare
   */
  getConsultantIcon(idNivel) {
    if (!idNivel) return '👥';
    if (idNivel <= 10) return '👑';
    if (idNivel <= 20) return '💼';
    if (idNivel <= 30) return '📋';
    if (idNivel <= 40) return '👤';
    return '👥';
  },

  /**
   * Întârziere asincronă
   * @param {number} ms - Milisecunde de așteptat
   * @returns {Promise} Promise care se rezolvă după timpul specificat
   */
  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  },

  /**
   * Curăță textul HTML generat de Access (RTF)
   * @param {string} htmlText - Textul HTML de curățat
   * @returns {string} Textul curățat
   */
  cleanAccessRichText(htmlText) {
    if (!htmlText || typeof htmlText !== 'string') {
      return '';
    }

    let cleanedText = htmlText;

    // 1. Elimină tag-urile goale
    cleanedText = cleanedText.replace(/<(\w+)[^>]*><\/\1>/gi, '');

    // 2. Elimină <div></div> goale și cu &nbsp;
    cleanedText = cleanedText.replace(/<div[^>]*>(\s|&nbsp;)*<\/div>/gi, '');

    // 3. Elimină <span> goale sau cu doar whitespace
    cleanedText = cleanedText.replace(/<span[^>]*>\s*<\/span>/gi, '');

    // 4. Elimină <p> goale
    cleanedText = cleanedText.replace(/<p[^>]*>\s*<\/p>/gi, '');

    // 5. Convertește <BR><BR> sau <br><br> consecutive într-un singur <br>
    cleanedText = cleanedText.replace(/(<br\s*\/?>\s*){2,}/gi, '<br>');

    // 6. Elimină stilurile inline Access
    cleanedText = cleanedText.replace(/style="[^"]*"/gi, '');

    // 7. Elimină class-urile Access
    cleanedText = cleanedText.replace(/class="[^"]*"/gi, '');

    return cleanedText.trim();
  },

  /**
   * Extrage textul curat pentru tooltip-uri (fără HTML)
   * @param {string} htmlText - Textul HTML
   * @returns {string} Textul curat pentru tooltip
   */
  stripHtmlForTooltip(htmlText) {
    if (!htmlText || typeof htmlText !== 'string') {
      return '';
    }

    // Înlocuiește <br> cu space pentru citire mai ușoară
    let cleanText = htmlText.replace(/<br\s*\/?>/gi, ' ');

    // Elimină toate tag-urile HTML
    cleanText = cleanText.replace(/<[^>]*>/g, '');

    // Decodează entitățile HTML
    const textarea = document.createElement('textarea');
    textarea.innerHTML = cleanText;
    cleanText = textarea.value;

    // Curăță spațiile multiple și trim
    cleanText = cleanText.replace(/\s+/g, ' ').trim();

    // Limitează lungimea pentru tooltip
    return this.truncateText(cleanText, 200);
  },
};
