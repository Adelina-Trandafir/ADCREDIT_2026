export const filterUtilsMixin = {
  /**
   * 🎭 ACCORDION BEHAVIOR
   */
  initializeAccordionBasedOnType() {
    // Determină opțiunea default bazată pe disponibilitate
    const defaultActiveOption = this.determineDefaultOption();

    this.configurePartialOption(defaultActiveOption === 'partial');
    this.configureRangeOption(defaultActiveOption === 'range');
    this.configureExactOption(defaultActiveOption === 'exact');

    return defaultActiveOption;
  },

  determineDefaultOption() {
    if (this.currentColumn.filterConfig) {
      const existingType = this.currentColumn.filterConfig.type;
      if (existingType === 'partial' && this.isPartialAvailable) return 'partial';
      if (existingType === 'range' && this.isRangeAvailable) return 'range';
      if (existingType === 'exact' && this.isExactAvailable) return 'exact';
    }

    // Pentru date și int, preferă range dacă e disponibil
    if (this.currentColumnType === 'date' || this.currentColumnType === 'int') {
      if (this.isRangeAvailable) return 'range';
      if (this.isPartialAvailable) return 'partial';
      if (this.isExactAvailable) return 'exact';
    }

    // Pentru varchar și text, preferă partial dacă e disponibil
    if (this.currentColumnType === 'varchar' || this.currentColumnType === 'text') {
      if (this.isPartialAvailable) return 'partial';
      if (this.isRangeAvailable) return 'range';
      if (this.isExactAvailable) return 'exact';
    }

    // Fallback
    if (this.isPartialAvailable) return 'partial';
    if (this.isExactAvailable) return 'exact';
    if (this.isRangeAvailable) return 'range';

    return 'partial';
  },

  configurePartialOption(isDefault) {
    if (!this.isPartialAvailable) {
      // Ascunde opțiunea și dezactivează input-ul
      this.partialFilterContainer.classList.add('disabled', 'hidden');
      this.partialFilterContainer.classList.remove('expanded', 'active', 'collapsed');
      this.partialTextElement.disabled = true;
    } else if (isDefault) {
      // Afișează și activează opțiunea
      this.partialFilterContainer.classList.remove('disabled', 'hidden', 'collapsed');
      this.partialFilterContainer.classList.add('active', 'expanded');
      this.partialTextElement.disabled = false;
      this.partialTextElement.focus();
    } else {
      // Afișează opțiunea, dar o lasă inactivă
      this.partialFilterContainer.classList.remove('disabled', 'hidden', 'expanded', 'active');
      this.partialFilterContainer.classList.add('collapsed');
      this.partialTextElement.disabled = true;
    }

    this.optionButtons['partial'].checked = isDefault;
  },

  configureRangeOption(isDefault) {
    if (!this.isRangeAvailable) {
      // Ascunde opțiunea și dezactivează input-ul
      this.rangeFilterContainer.classList.add('disabled', 'hidden');
      this.rangeFilterContainer.classList.remove('expanded', 'active', 'collapsed');
      this.rangeFromElement.disabled = true;
      this.rangeToElement.disabled = true;
    } else if (isDefault) {
      // Afișează și activează opțiunea
      this.rangeFilterContainer.classList.remove('disabled', 'hidden', 'collapsed');
      this.rangeFilterContainer.classList.add('active', 'expanded');
      this.rangeFromElement.disabled = false;
      this.rangeToElement.disabled = false;
      this.rangeFromElement.focus();
    } else {
      // Afișează opțiunea, dar o lasă inactivă
      this.rangeFilterContainer.classList.remove('disabled', 'hidden', 'expanded', 'active');
      this.rangeFilterContainer.classList.add('collapsed');
      this.rangeFromElement.disabled = true;
      this.rangeToElement.disabled = true;
    }

    this.optionButtons['range'].checked = isDefault;
  },

  configureExactOption(isDefault) {
    if (!this.isExactAvailable) {
      // Ascunde opțiunea și dezactivează combobox-ul
      this.exactFilterContainer.classList.add('disabled', 'hidden');
      this.exactFilterContainer.classList.remove('expanded', 'active', 'collapsed');
      this.exactCombobox?.setEnabled(false);
    } else if (isDefault) {
      // Afișează și activează opțiunea
      this.exactFilterContainer.classList.remove('disabled', 'hidden', 'collapsed');
      this.exactFilterContainer.classList.add('active', 'expanded');
      this.exactCombobox?.setEnabled(true);
    } else {
      // Afișează opțiunea, dar o lasă inactivă
      this.exactFilterContainer.classList.remove('disabled', 'hidden', 'expanded', 'active');
      this.exactFilterContainer.classList.add('collapsed');
      this.exactCombobox?.setEnabled(false);
    }

    this.optionButtons['exact'].checked = isDefault;
  },

  focusAppropriateInputForType(selectedType) {
    if (selectedType === 'exact' && this.exactCombobox && this.exactCombobox.input) {
      this.exactCombobox.input.focus();
    } else if (selectedType === 'partial' && this.partialTextElement) {
      this.partialTextElement.focus();
    } else if (selectedType === 'range' && this.rangeFromElement) {
      this.rangeFromElement.focus();
    }
  },

  /**
   * 👁️ VISIBILITY TOGGLES
   */
  toggleExactFilterVisibility() {
    this.isExactAvailable =
      !this.currentColumnType ||
      this.currentColumnType === '' ||
      this.currentColumnType === 'varchar';

    if (!this.isExactAvailable || this.exactFilterContainer) return;

    if (this.isExactAvailable) {
      this.exactFilterContainer.classList.remove('expanded');
      this.exactFilterContainer.classList.add('collapsed');
    } else {
      this.exactFilterContainer.classList.add('expanded');
      this.exactFilterContainer.classList.remove('collapsed');
    }
  },

  togglePartialFilterVisibility() {
    this.isPartialAvailable =
      !this.currentColumnType ||
      this.currentColumnType === '' ||
      this.currentColumnType === 'varchar' ||
      this.currentColumnType === 'text';

    if (!this.isPartialAvailable || this.partialFilterContainer) return;
    if (this.isPartialAvailable) {
      this.partialFilterContainer.classList.remove('expanded');
      this.partialFilterContainer.classList.add('collapsed');
    } else {
      this.partialFilterContainer.classList.add('expanded');
      this.partialFilterContainer.classList.remove('collapsed');
    }
  },

  toggleRangeFilterVisibility() {
    this.isRangeAvailable =
      !this.currentColumnType ||
      this.currentColumnType === 'date' ||
      this.currentColumnType === 'int';

    if (!this.isRangeAvailable || !this.rangeFilterContainer) return;
    if (this.isRangeAvailable) {
      this.rangeFilterContainer.classList.remove('expanded');
      this.rangeFilterContainer.classList.add('collapsed');
    } else {
      this.rangeFilterContainer.classList.add('expanded');
      this.rangeFilterContainer.classList.remove('collapsed');
    }
  },

  /**
   * 🔄 UPDATE DISPONIBILITATE OPȚIUNI - nefolosita
   */
  updateFilterOptionsAvailability(currentColumnType) {
    this.isExactAvailable =
      !currentColumnType || currentColumnType === '' || currentColumnType === 'varchar';
    this.isPartialAvailable =
      !currentColumnType ||
      currentColumnType === '' ||
      currentColumnType === 'varchar' ||
      currentColumnType === 'text';
    this.isRangeAvailable =
      !this.currentColumnType ||
      this.currentColumnType === 'date' ||
      this.currentColumnType === 'int';
  },
};
