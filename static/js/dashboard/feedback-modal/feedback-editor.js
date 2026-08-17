export const feedbackEditorMixin = {
  /**
   * ✅ FIXED: Setup toolbar button listeners
   */
  setupToolbarListeners() {
    // Format buttons
    this.toolBarElement?.querySelectorAll('.feedback-toolbar-btn').forEach((btn) => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        const command = btn.dataset.command;
        document.execCommand(command, false, null);
        // ✅ FIXED: Focus pe editor în loc de toolbar
        this.feedbackElement.focus();
        // Actualizează toolbar după comandă
        setTimeout(() => this.updateToolbarState(), 10);
      });
    });

    // Color picker
    this.colorPickerElement?.addEventListener('change', (e) => {
      document.execCommand('foreColor', false, e.target.value);
      // ✅ FIXED: Focus pe editor
      this.feedbackElement.focus();
    });
  },

  setupEditorListeners() {
    if (this.areModalListenersSet) return;

    // Input event - pentru taste
    this.addDOMListener(this.feedbackElement, 'input', () => this.handleEditorInput());

    // Click event - pentru mouse navigation
    this.addDOMListener(this.feedbackElement, 'click', () => this.updateToolbarState());

    // Keyup event - pentru săgeți și alte navigații
    this.addDOMListener(this.feedbackElement, 'keyup', (e) => {
      // Doar pentru taste de navigare (săgeți, Home, End, etc.)
      const navKeys = [
        'ArrowUp',
        'ArrowDown',
        'ArrowLeft',
        'ArrowRight',
        'Home',
        'End',
        'PageUp',
        'PageDown',
      ];
      if (navKeys.includes(e.key)) {
        this.updateToolbarState();
      }
    });

    // SelectionChange event - pentru orice schimbare de selecție
    this.addDOMListener(document, 'selectionchange', () => {
      // Verifică dacă selecția e în editorul nostru
      const selection = window.getSelection();
      if (selection.rangeCount > 0) {
        const range = selection.getRangeAt(0);
        if (this.feedbackElement.contains(range.commonAncestorContainer)) {
          this.updateToolbarState();
        }
      }
    });
  },

  /**
   * Handler pentru input în editor
   */
  handleEditorInput() {
    const text = this.feedbackElement.textContent || '';
    const charCount = text.trim().length;

    this.counterElement.textContent = charCount;

    this.log(`✏️ Editor conținut: ${charCount} caractere`);

    // Actualizează starea toolbar-ului
    this.updateToolbarState();

    // Validează formularul
    this.validateForm();
  },

  /**
   * 🆕 Actualizează starea butoanelor din toolbar
   * în funcție de formatul textului la cursor
   */
  updateToolbarState() {
    if (!this.toolBarElement || !this.colorPickerElement) {
      return;
    }

    try {
      // 1️⃣ Verifică dacă editorul are focus sau dacă avem o selecție validă
      const selection = window.getSelection();
      if (!selection.rangeCount || !this.feedbackElement.contains(selection.anchorNode)) {
        // Clear all selections dacă nu suntem în editor
        this.clearToolbarSelection();
        return;
      }

      // 2️⃣ Detectează formatarea curentă
      const isBold = document.queryCommandState('bold');
      const isItalic = document.queryCommandState('italic');
      const isUnderline = document.queryCommandState('underline');
      const isList = this.isInsideListItem();
      const currentColor = this.getCurrentTextColor();

      // 3️⃣ Actualizează butoanele
      this.toolBarElement.querySelectorAll('.feedback-toolbar-btn').forEach((btn) => {
        const command = btn.dataset.command;
        let isSelected = false;

        switch (command) {
          case 'bold':
            isSelected = isBold;
            break;
          case 'italic':
            isSelected = isItalic;
            break;
          case 'underline':
            isSelected = isUnderline;
            break;
          case 'insertUnorderedList':
            isSelected = isList;
            break;
        }

        // Toggle clasa .selected
        if (isSelected) {
          btn.classList.add('selected');
        } else {
          btn.classList.remove('selected');
        }
      });

      // 4️⃣ Actualizează color picker
      if (currentColor) {
        this.colorPickerElement.value = currentColor;
      }

      // 5️⃣ Log pentru debugging (opțional)
      this.log('🎨 Toolbar state actualizat:', {
        bold: isBold,
        italic: isItalic,
        underline: isUnderline,
        list: isList,
        color: currentColor,
      });
    } catch (error) {
      this.log.error('❌ Eroare la actualizarea toolbar state:', error);
    }
  },

  /**
   * 🆕 Verifică dacă cursorul este într-un <li>
   */
  isInsideListItem() {
    try {
      const selection = window.getSelection();
      if (!selection.rangeCount) return false;

      let node = selection.anchorNode;

      // Dacă node e text, ia parentul
      if (node.nodeType === Node.TEXT_NODE) {
        node = node.parentElement;
      }

      // Caută <li> în ierarhie până la editor
      while (node && node !== this.feedbackElement) {
        if (node.tagName === 'LI') {
          return true;
        }
        node = node.parentElement;
      }

      return false;
    } catch (error) {
      return false;
    }
  },

  /**
   * 🆕 Obține culoarea curentă a textului la cursor
   * Returnează culoare în format HEX (#RRGGBB)
   */
  getCurrentTextColor() {
    try {
      // Metodă 1: Încearcă queryCommandValue
      const colorValue = document.queryCommandValue('foreColor');

      if (colorValue) {
        // Convertește la HEX
        return this.rgbToHex(colorValue);
      }

      // Metodă 2: Verifică computed style al nodului curent
      const selection = window.getSelection();
      if (selection.rangeCount > 0) {
        let node = selection.anchorNode;

        // Dacă e text node, ia parentul
        if (node.nodeType === Node.TEXT_NODE) {
          node = node.parentElement;
        }

        if (node && node.nodeType === Node.ELEMENT_NODE) {
          const computedStyle = window.getComputedStyle(node);
          const color = computedStyle.color;
          return this.rgbToHex(color);
        }
      }

      // Fallback: negru
      return '#000000';
    } catch (error) {
      return '#000000';
    }
  },

  /**
   * 🆕 Convertește RGB/RGBA la HEX
   */
  rgbToHex(color) {
    try {
      // Dacă e deja hex, returnează
      if (color.startsWith('#')) {
        // Asigură format #RRGGBB (6 caractere)
        if (color.length === 7) return color;
        if (color.length === 4) {
          // #RGB -> #RRGGBB
          return '#' + color[1] + color[1] + color[2] + color[2] + color[3] + color[3];
        }
        return color;
      }

      // Parse RGB/RGBA format: rgb(r, g, b) sau rgba(r, g, b, a)
      const match = color.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);

      if (match) {
        const r = parseInt(match[1]);
        const g = parseInt(match[2]);
        const b = parseInt(match[3]);

        // Convertește la hex
        const hex =
          '#' +
          r.toString(16).padStart(2, '0') +
          g.toString(16).padStart(2, '0') +
          b.toString(16).padStart(2, '0');

        return hex;
      }

      // Fallback
      return '#000000';
    } catch (error) {
      return '#000000';
    }
  },

  /**
   * 🆕 Curăță toate selecțiile din toolbar
   */
  clearToolbarSelection() {
    // Scoate clasa .selected de pe toate butoanele
    this.toolBarElement?.querySelectorAll('.feedback-toolbar-btn').forEach((btn) => {
      btn.classList.remove('selected');
    });

    // Resetează color picker la negru
    if (this.colorPickerElement) {
      this.colorPickerElement.value = '#000000';
    }
  },

  /**
   * Verifică disponibilitatea spell checker-ului
   */
  checkSpellChecker() {
    if (this.spellCheckBannerDismissed) {
      return;
    }

    const banner = this.modalElement.querySelector('#spell-check-banner');
    const editor = this.modalElement.querySelector('#feedback-editor');

    setTimeout(() => {
      const hasSpellCheck = editor.spellcheck && navigator.language.includes('ro');

      if (!hasSpellCheck) {
        banner.style.display = 'block';
      }
    }, 1000);
  },

  /**
   * Ascunde banner-ul spell checker
   */
  dismissSpellCheckBanner() {
    const banner = this.modalElement.querySelector('#spell-check-banner');
    banner.style.display = 'none';
    localStorage.setItem('feedback-spell-banner-dismissed', 'true');
    this.spellCheckBannerDismissed = true;
  },

  /**
   * Obține conținutul editorului (HTML și text)
   */
  getEditorContent() {
    const editor = this.feedbackElement;

    if (!editor) {
      this.log.error('❌ Editor element nu există');
      return { html: '', text: '', charCount: 0 };
    }

    const html = editor.innerHTML;
    const text = editor.textContent || '';
    const charCount = text.trim().length;

    this.log(`📄 Conținut editor: ${charCount} caractere`);

    return {
      html: html,
      text: text.trim(),
      charCount: charCount,
    };
  },

  /**
   * Șterge tot conținutul editorului și resetează counter-ul
   */
  clearEditor() {
    if (!this.feedbackElement) {
      this.log.error('❌ Editor element nu există');
      return;
    }

    this.feedbackElement.innerHTML = '';
    this.feedbackElement.contentEditable = 'true';

    if (this.counterElement) {
      this.counterElement.textContent = '0';
    }

    this.editorContent = '';

    // Clear toolbar selection
    this.clearToolbarSelection();

    this.log('🧹 Editor curățat');
  },

  /**
   * Activează/dezactivează posibilitatea de editare în editor
   */
  setEditorEditable(enabled) {
    if (!this.feedbackElement) {
      this.log.error('❌ Editor element nu există');
      return;
    }

    this.feedbackElement.contentEditable = enabled ? 'true' : 'false';

    if (enabled) {
      this.feedbackElement.focus();
      this.log('✏️ Editor activat pentru editare');
    } else {
      this.feedbackElement.blur();
      this.log('🔒 Editor blocat pentru editare');
    }
  },

  /**
   * Actualizează culoarea de fundal a editorului
   */
  updateEditorHeaderAndFooter(color) {
    if (!this.headerElement || !this.footerElement) return;

    // RGB din hex
    // const [r, g, b] = color.match(/[a-f\d]{2}/gi).map((c) => parseInt(c, 16));

    this.modalElement.style.setProperty('--status-color-left', color);
    this.modalElement.style.setProperty('--status-color-right', color);

    if (!this.headerElement.classList.contains('with-status')) {
      this.headerElement.classList.add('with-status');
      this.footerElement.classList.add('with-status');
    }
  },
};
