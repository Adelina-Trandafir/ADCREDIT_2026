// js/details-panel/details-panel-form-this.js
/**
 * ========== DETAILS PANEL FORM this - Modul pentru gestionarea formularului ==========
 * Gestionează toate operațiunile legate de formular: setup, populare, validare, colectare date
 *
 * @version 2.0.0 - Extras din details-panel-this.js
 */

export const FormManagerMixin = {
  /**
   * Configurează toate componentele formularului
   */
  setupFormComponents() {
    const normalInputs = this.formElement.querySelectorAll(
      'input[type="text"], input[type="email"], input[type="date"], input[type="datetime-local"]'
    );

    normalInputs.forEach((input) => {
      if (!input.hasAttribute('data-custom-datetime') && !input.hasAttribute('data-custom-date')) {
        this.components.formInputs.set(input.name, input);
        this.addDOMListener(input, 'input', () => this.markDirty());
      }
    });

    const nationalIdInput = this.formElement.querySelector('input[name="CNPClient"]');
    if (nationalIdInput) {
      this.components.nationalId = new this.NationalID(nationalIdInput, {
        autoFormat: true, // formatare vizuală
        autoValidate: true, // validare la blur
        showError: true, // mesaj de eroare
        debugMode: true,
        ListenerTracker: this.ListenerTracker, // folosește funcția de atașare event personalizată

        onValid: (result) => {
          this.log('✅ Valid:', result);
          // {valid: true, sex: 'M', dataNasterii: '1990-01-15',
          //  judet: 'B', categorie: 'Rezident', steag: 'ro', cnp: '...'}
        },

        onInvalid: (nationalId) => {
          this.log.error('❌ Invalid:', nationalId);
        },

        onChange: (digits) => {
          this.log('📝 Schimbare:', digits);
        },
      });
    }

    const phoneInputs = this.formElement.querySelectorAll('input[type="phone"]');

    phoneInputs.forEach((input) => {
      const phoneContainer = this.panelElement.querySelector(`#${input.name}`);

      if (!phoneContainer) {
        this.log.error(`Container pentru telefon ${input.name} nu a fost găsit`);
        return;
      }

      let fieldConfig = null;
      for (const field of Object.values(this.config.fields)) {
        if (field.id === input.name) {
          fieldConfig = field;
          break;
        }
      }

      this.components.phoneClient = new this.PhoneTools(phoneContainer, {
        defaultCountry: 'RO',
        autoFormat: true, // formatare automată
        autoDetect: true, // detectare țară
        debugMode: true,
        flagAlwaysDisabled: true,
        ListenerTracker: this.ListenerTracker,
        onCountryDetected: (country) => {
          this.log('Țară:', country.name);
        },
      });
    });

    const dateInputs = this.formElement.querySelectorAll(
      'input[data-custom-datetime="true"],input[data-custom-date="true"]'
    );

    dateInputs.forEach((input) => {
      //input.style.padding = '0px 8px 0px 8px';

      const isCustomDateTime = input.hasAttribute('data-custom-datetime');
      const isCustomDate = input.hasAttribute('data-custom-date');

      const dateContainer = this.panelElement.querySelector(`#${input.name}`);

      if (!dateContainer) {
        this.log.error(`Container pentru data ${input.name} nu a fost găsit`);
        return;
      }

      // Caută configurația pentru acest câmp
      let fieldConfig = null;
      for (const field of Object.values(this.config.fields)) {
        if (field.id === input.name) {
          fieldConfig = field;
          break;
        }
      }

      const dateConfig = fieldConfig ? fieldConfig.dateConfig : {};

      if (isCustomDate) {
        dateConfig.customDate = true;
        dateConfig.showTimeSelector = false;
        input.setAttribute('data-input-type', 'date');
      } else if (isCustomDateTime) {
        dateConfig.customDateTime = true;
        dateConfig.showTimeSelector = true;
        input.setAttribute('data-input-type', 'datetime-local');
      }

      const calendar = this.calendarManager.createCalendarForInput(input, dateConfig, false);
      this.components.dateInputs.set(input.name, calendar);
    });

    // Setup Combobox pentru Județ
    const judetContainer = this.panelElement.querySelector('#div_JudetClient');
    //judetContainer.style.width = '70%';
    this.components.comboboxJudet = new this.Combobox(judetContainer, {
      placeholder: 'Se încarcă județe...',
      readonly: true,
    });

    const judetInput = this.components.comboboxJudet.input;
    if (judetInput) {
      judetInput.id = 'JudetClient';
      judetInput.name = 'JudetClient';
    }

    // Setup TreeView pentru Sursă
    const sursaContainer = this.panelElement.querySelector('#div_SursaAgent');

    this.components.treeviewSursa = new this.TreeView(sursaContainer, {
      placeholder: 'Se încarcă datele...',
      selectableLevel: 2,
      overlayMode: true,
      showSearchBox: true,
      showTwoRowsInInput: true,
      onSelect: () => {
        this.handleSourceAgentSelectionChange(this.components.treeviewSursa.getSelection());
      },
    });

    const treeviewSursa = this.components.treeviewSursa.input;
    if (treeviewSursa) {
      treeviewSursa.id = 'NumeAgent';
      treeviewSursa.name = 'NumeAgent';
    }

    // Setup TreeView pentru Consultanți
    const consultantContainer = this.panelElement.querySelector('#div_NumeConsultant');
    if (consultantContainer) {
      this.components.treeviewConsultant = new this.TreeView(consultantContainer, {
        placeholder: 'Se încarcă consultanții...',
        overlayMode: true,
        showSearchBox: true,
        requireDoubleClick: true,
      });

      const treeviewConsultant = this.components.treeviewConsultant.input;
      if (treeviewConsultant) {
        treeviewConsultant.id = 'NumeConsultant';
        treeviewConsultant.name = 'NumeConsultant';
      }
    } else {
      this.log.error('Container pentru consultanți nu a fost găsit');
    }

    this.log('🔧 Componente form configurate cu placeholder-e de loading');
  },

  /**
   * Populează formularul cu date
   * @param {Object} data - Datele pentru populare
   */
  populateForm(data) {
    this.log('📊 Populez formularul cu date', data);
    if (!data) {
      this.clearForm();
      return;
    };
    
    const pad = (n) => String(n).padStart(2, '0');

    const normalize = (val, type = 'text') => {
      if (val === null || val === undefined) return '';

      if (type === 'date') {
        let d = new Date(val);
        if (isNaN(d)) return '';
        return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
      }

      if (type === 'datetime-local') {
        let d = new Date(val);
        if (isNaN(d)) return '';
        return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
      }

      return String(val).trim();
    };

    this.config.fields.forEach(
      ({
        id,
        type,
        valueField,
        textField,
        valueSecondaryField,
        textSecondaryField,
        showTwoRowsInInput,
      }) => {
        if (['text', 'caption', 'label'].includes(type)) {
          const input = this.components.formInputs.get(id);
          if (input) {
            input.value = normalize(data[0][id], type);
            input.dataset.originalValue = input.value;
          }
          return;
        }

        if (['date', 'datetime-local'].includes(type)) {
          const input = this.components.dateInputs.get(id);
          if (input) {
            input.setDate(data[0][id]);
          }
          return;
        }

        if (type === 'national-id') {
          if (this.components.nationalId) {
            const nationalIdVal = normalize(data[0][id], 'text');
            this.components.nationalId.setNationalId(nationalIdVal, data[0].Tara);
          }
          return;
        }

        if (type === 'phone') {
          if (this.components.phoneClient) {
            const phoneVal = normalize(data[0][id], 'text');
            this.components.phoneClient.setNumber(phoneVal);
          }
          return;
        }

        if (type === 'combo') {
          const comp = this.components[`combobox${id.replace('Client', '')}`];
          if (comp) {
            const val = data[0][valueField];
            const txt = data[0][textField];
            comp.setValue(val ? String(val) : null, txt || '');
            comp.input.value = normalize(txt);
          }
          return;
        }

        if (type === 'tree') {
          let comp = null;
          if (id.includes('NumeAgent')) comp = this.components.treeviewSursa;
          if (id.includes('Consultant')) comp = this.components.treeviewConsultant;

          if (comp) {
            const val = data[0][valueField];
            const txt = data[0][textField];

            if (showTwoRowsInInput) {
              const val2 = data[0][valueSecondaryField];
              const txt2 = data[0][textSecondaryField];
              comp.set2Values(val, txt, val2, txt2, null);
              return;
            } else comp.setValue(val, txt, data[0][valueField] || null);
          }
          return;
        }
      }
    );

    this.isDirty = false;
    this.components.phoneClient.setEnabled(false);
  },

  /**
   * Colectează datele din formular
   * @returns {Object} Datele colectate
   */
  collectFormData() {
    const data = {};

    this.components.formInputs.forEach((input, fieldName) => {
      data[fieldName] = input.value;
    });

    if (this.components.comboboxJudet) {
      data.IdJudet = this.components.comboboxJudet.getSelectedValue();
      data.Judet = this.components.comboboxJudet.getSelectedText();
    }

    if (this.components.treeviewSursa) {
      const treeSelection = this.components.treeviewSursa.getSelection();
      data.IdSursa = treeSelection.parentId || treeSelection.id;
      data.Sursa = treeSelection.parentLabel || treeSelection.label;
      if (treeSelection.isChild) {
        data.IdAgent = treeSelection.id;
        data.NumeAgent = treeSelection.label;
      }
    }

    if (this.components.treeviewConsultant) {
      const treeSelection = this.components.treeviewConsultant.getSelection();
      data.IdConsultant = treeSelection.id;
      data.NumeConsultant = treeSelection.label;
    }

    // Colectează și datele din dateInputs
    this.components.dateInputs.forEach((calendar, fieldName) => {
      const value = calendar.getValue();
      if (value) {
        data[fieldName] = value;
      }
    });

    return data;
  },

  validateForm(data) {
    const errors = [];

    if (data.CNPClient && !this.isValidCNP(data.CNPClient)) {
      errors.push({ field: 'CNPClient', message: 'CNP invalid' });
    }

    if (data.EmailClient && !this.isValidEmail(data.EmailClient)) {
      errors.push({ field: 'EmailClient', message: 'Email invalid' });
    }

    if (data.TelefonClient && !this.isValidPhone(data.TelefonClient)) {
      errors.push({ field: 'TelefonClient', message: 'Număr de telefon invalid' });
    }

    return {
      isValid: errors.length === 0,
      errors,
    };
  },

  clearForm() {
    this.components.formInputs.forEach((input) => {
      input.value = '';
    });

    if (this.components.comboboxJudet) {
      this.components.comboboxJudet.clear();
    }

    if (this.components.treeviewSursa) {
      this.components.treeviewSursa.clear();
    }

    if (this.components.treeviewConsultant) {
      this.components.treeviewConsultant.clear();
    }

    this.isDirty = false;
  },

  markDirty() {
    this.isDirty = true;
  },

  disableAllControls() {
    this.log('🔒 Dezactivez toate controalele');

    // Dezactivează input-urile normale
    this.components.formInputs.forEach((input) => {
      input.disabled = true;
    });

    /// Dezactivează input-urile de dată
    this.components.dateInputs.forEach((calendar) => {
      // calendar.input.disabled = true;
      calendar.setEnabled(false);
      if (calendar.calendarIcon) {
        calendar.calendarIcon.style.pointerEvents = 'none';
        calendar.calendarIcon.style.opacity = '0.5';
      }
    });

    // Dezactivează input-urile de telefon
    if (this.components.phoneClient) {
      this.components.phoneClient.setEnabled(false);
    }

    // Dezactivează combobox-urile
    if (this.components.comboboxJudet) {
      this.components.comboboxJudet.setEnabled(false);
    }

    // Dezactivează treeview-urile
    if (this.components.treeviewSursa) {
      this.components.treeviewSursa.setEnabled(false);
    }

    if (this.components.treeviewConsultant) {
      this.components.treeviewConsultant.setEnabled(false);
    }

    // Dezactivează butoanele
    const saveBtn = this.panelElement.querySelector('#btnSaveDetails');
    const cancelBtn = this.panelElement.querySelector('#btnCancelDetails');

    if (saveBtn) saveBtn.disabled = true;
    if (cancelBtn) cancelBtn.disabled = false; // Cancel rămâne activ

    this.log('✅ Toate controalele dezactivate');
  },

  enableAllControls() {
    this.log('🔓 Activez toate controalele');
    // Activează input-urile normale
    this.components.formInputs.forEach((input) => {
      input.disabled = false;
    });

    // Activează input-urile de dată
    this.components.dateInputs.forEach((calendar) => {
      calendar.setEnabled(true);
    });

    // Activează combobox-urile
    if (this.components.comboboxJudet) {
      this.components.comboboxJudet.setEnabled(true);
    }
    // Activează treeview-urile
    if (this.components.treeviewSursa) {
      this.components.treeviewSursa.setEnabled(true);
    }
    if (this.components.treeviewConsultant) {
      this.components.treeviewConsultant.setEnabled(true);
    }
    // Activează butoanele
    if (this.saveButton) this.saveButton.disabled = false;
    if (this.cancelButton) this.cancelButton.disabled = false;
    this.log('✅ Toate controalele activate');
  },

  /**
   * Construiește structura de arbore pentru surse și agenți
   * @param {Array} flatData - Lista plată de surse și agenți
   * @returns {Array} Structura de arbore formatată pentru TreeView
   */
  buildSurseAgentiTree(flatData) {
    const tree = [];
    const parents = new Map();

    // Construiește nodurile părinte (surse)
    flatData.forEach((item) => {
      if (!parents.has(item.IdSursa)) {
        parents.set(item.IdSursa, {
          id: item.IdSursa,
          label: item.Sursa,
          isParent: true,
          children: [],
        });
      }

      // Adaugă copiii (agenții) pentru fiecare sursă
      if (item.IDAgent) {
        parents.get(item.IdSursa).children.push({
          id: item.IDAgent,
          label: item.NumeAgent,
          parentId: item.IdSursa,
          isChild: true,
        });
      }
    });

    // Convertește Map-ul în array
    parents.forEach((parent) => tree.push(parent));
    return tree;
  },

  /**
   * Construiește structura de arbore pentru consultanți
   * @param {Array} consultants - Lista de consultanți
   * @param {Function} logFunction - Funcția de logging (opțional)
   * @returns {Array} Structura de arbore formatată pentru TreeView
   */
  buildConsultantsTree(consultants) {
    this.log('🔨 Construiesc arborele de consultanți...');

    const nodeMap = new Map();
    const roots = [];

    // Creează toate nodurile
    consultants.forEach((consultant) => {
      const node = {
        id: consultant.IdConsultant,
        text: consultant.NumeConsultant,
        data: consultant,
        children: [],
        parent: null,
      };
      nodeMap.set(consultant.IdConsultant, node);
    });

    // Construiește relațiile părinte-copil
    consultants.forEach((consultant) => {
      const node = nodeMap.get(consultant.IdConsultant);
      if (consultant.IdParinte && nodeMap.has(consultant.IdParinte)) {
        const parent = nodeMap.get(consultant.IdParinte);
        parent.children.push(node);
        node.parent = parent;
      } else {
        roots.push(node);
      }
    });

    return this.convertToTreeViewFormat(roots);
  },

  /**
   * Convertește nodurile într-un format compatibil cu TreeView
   * @param {Array} nodes - Nodurile de convertit
   * @param {number} level - Nivelul curent în arbore
   * @returns {Array} Nodurile formatate pentru TreeView
   */
  convertToTreeViewFormat(nodes, level = 0) {
    return nodes.map((node) => ({
      id: node.id,
      text: node.text,
      data: node.data,
      children:
        node.children?.length > 0 ? this.convertToTreeViewFormat(node.children, level + 1) : [],
      expanded: level < 2, // Expandează primele 2 niveluri
      icon: this.getConsultantIcon(node.data?.IdNivel),
      tooltip: `${node.text} - Nivel ${node.data?.IdNivel}`,
    }));
  },
};
