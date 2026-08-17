export const feedbackFormMixin = {
  /**
   * Reset formular
   */
  resetForm() {
    // Curăță editorul
    this.clearEditor();

    // Curăță câmpurile (status + calendar)
    this.clearFields();

    // Validează formularul (va dezactiva butonul Save)
    this.validateForm();

    this.log('🔄 Formular resetat complet');
  },

  /**
   * Validează formularul
   */
  validateForm() {
    const editor = this.feedbackElement;
    const dateInput = this.calendarElement;
    const saveBtn = this.saveBtnElement;

    const text = (editor.textContent || '').trim();
    const hasValidStatus = this.statusCombobox && this.statusCombobox.getSelectedValue() !== '';
    const hasValidText = text.length >= 10;

    let hasValidDate = true;
    if (this.selectedStatus && this.selectedStatus.IDSG === 2) {
      hasValidDate = dateInput.value.trim() !== '';
    }

    const isValid = hasValidStatus && hasValidText && hasValidDate;

    saveBtn.disabled = !isValid;
  },
};
