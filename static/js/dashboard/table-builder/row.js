// File: static/js/dashboard/row.js
/**
 * 📊 ROW CLASS - GESTIONAREA DATELOR ȘI STĂRII RÂNDURILOR
 *
 * RESPONSABILITĂȚI:
 * ✅ Gestionează datele fiecărui rând din tabel
 * ✅ Tracking pentru interacțiuni (click, hover, select)
 * ✅ Management pentru stări (selected, highlighted, filtered)
 * ✅ Formatare și styling pentru celule
 * ✅ Performance metrics pentru rânduri
 * ✅ Sincronizare cu global state
 *
 * SIMILAR CU COLUMN CLASS DAR PENTRU RÂNDURI!
 */

/**
 * 📊 ROW CLASS - Gestionarea unui rând din tabel
 */
class Row {
  constructor(rowData, rowIndex = 0) {
    // 🔧 PROPRIETĂȚI DE BAZĂ
    // Pentru această structură, ID-ul rândului va fi index-ul sau primul ID de coloană
    const firstColumnId = Object.keys(rowData)[0];
    this.id = rowData.Id; //`row-${rowData.Id}`;
    this.index = rowIndex;
    this.data = Object.fromEntries(Object.entries(rowData).filter(([key]) => key !== 'Id')); // Copiază toate datele rândului
    this.originalData = { ...rowData }; // Păstrează o copie pentru reset

    // 🎯 STATE MANAGEMENT
    this.isSelected = false;
    this.isHighlighted = false;
    this.isHovered = false;
    this.isVisible = true;
    this.isEditable = true;
    this.isModified = false;

    // 🎨 STYLING PROPERTIES
    this.backgroundColor = null;
    this.textColor = null;
    this.customCssClass = null;

    // 📈 PERFORMANCE TRACKING
    this.clickCount = 0;
    this.lastClickTime = 0;
    this.hoverTime = 0;
    this.lastHoverStart = 0;
    this.selectCount = 0;

    // 🔧 CELLS MANAGEMENT - pentru fiecare celulă din rând
    this.cells = new Map(); // id_coloana -> cell data
    this.modifiedCells = new Set(); // Set cu id-urile celulelor modificate

    // Procesează datele inițiale pentru celule
    this.processCellData(rowData);
  }

  /**
   * 🔧 PROCESARE INIȚIALĂ A DATELOR CELULELOR
   * Adaptată pentru structura: {10: {back_color, font_bold, value, ...}, 20: {...}, ...}
   */
  processCellData(rowData) {
    // Iterează prin toate ID-urile de coloane (10, 20, 30, etc.)
    Object.keys(rowData).forEach((columnId) => {
      const cellObject = rowData[columnId];

      // Verifică că avem un obiect valid cu formatare
      if (cellObject && typeof cellObject === 'object' && cellObject.value !== undefined) {
        this.cells.set(columnId, {
          value: cellObject.value,
          originalValue: cellObject.value,
          displayValue: cellObject.value,
          backgroundColor: cellObject.back_color || '#FFFFFF',
          textColor: cellObject.fore_color || '#000000',
          fontWeight: cellObject.font_bold ? 'bold' : 'normal',
          fontStyle: cellObject.font_italic ? 'italic' : 'normal',
          textDecoration: cellObject.font_underline ? 'underline' : 'none',
          isModified: false,
          hasCustomFormatting: true,
          // Păstrează obiectul original pentru referință
          originalCellObject: { ...cellObject },
        });
      } else {
        // Fallback pentru date neașteptate
        this.cells.set(columnId, {
          value: cellObject,
          originalValue: cellObject,
          displayValue: cellObject,
          backgroundColor: '#FFFFFF',
          textColor: '#000000',
          fontWeight: 'normal',
          fontStyle: 'normal',
          textDecoration: 'none',
          isModified: false,
          hasCustomFormatting: false,
          originalCellObject: null,
        });
      }
    });

    // this.log(
    //   `📊 Procesat rândul cu ${this.cells.size} celule (${Object.keys(rowData).join(', ')})`
    // );
  }

  /**
   * 🔧 CELL VALUE MANAGEMENT
   */
  getCellValue(columnId) {
    const cell = this.cells.get(columnId);
    return cell ? cell.value : null;
  }

  setCellValue(columnId, newValue) {
    const cell = this.cells.get(columnId);
    if (!cell) {
      this.log.error(`Celula ${columnId} nu există în rândul ${this.id}`);
      return false;
    }

    const oldValue = cell.value;
    cell.value = newValue;
    cell.displayValue = newValue;

    // Marchează celula ca modificată dacă valoarea s-a schimbat
    if (oldValue !== newValue) {
      cell.isModified = true;
      this.modifiedCells.add(columnId);
      this.isModified = true;
      this.log(`📝 Celula ${columnId} modificată: ${oldValue} → ${newValue}`);
    }

    return true;
  }

  getCellFormatting(columnId) {
    const cell = this.cells.get(columnId);
    if (!cell) return null;

    return {
      backgroundColor: cell.backgroundColor,
      textColor: cell.textColor,
      fontWeight: cell.fontWeight,
      fontStyle: cell.fontStyle,
      textDecoration: cell.textDecoration,
      hasCustomFormatting: cell.hasCustomFormatting,
    };
  }

  setCellFormatting(columnId, formatting) {
    const cell = this.cells.get(columnId);
    if (!cell) return false;

    cell.backgroundColor = formatting.backgroundColor || cell.backgroundColor;
    cell.textColor = formatting.textColor || cell.textColor;
    cell.fontWeight = formatting.fontWeight || cell.fontWeight;
    cell.fontStyle = formatting.fontStyle || cell.fontStyle;
    cell.textDecoration = formatting.textDecoration || cell.textDecoration;
    cell.hasCustomFormatting = true;

    this.log(`🎨 Formatare aplicată pentru celula ${columnId}`);
    return true;
  }

  /**
   * 🎯 SELECTION MANAGEMENT
   */
  setSelected(selected) {
    const wasSelected = this.isSelected;
    this.isSelected = selected;

    if (selected && !wasSelected) {
      this.selectCount++;
      this.log(`✅ Rândul ${this.id} selectat (total: ${this.selectCount})`);
    } else if (!selected && wasSelected) {
      this.log(`❌ Rândul ${this.id} deselectat`);
    }
  }

  toggleSelected() {
    this.setSelected(!this.isSelected);
    return this.isSelected;
  }

  /**
   * 🎭 HOVER MANAGEMENT
   */
  setHovered(hovered) {
    if (hovered && !this.isHovered) {
      this.lastHoverStart = Date.now();
    } else if (!hovered && this.isHovered) {
      this.hoverTime += Date.now() - this.lastHoverStart;
    }
    this.isHovered = hovered;
  }

  /**
   * 🎨 HIGHLIGHTING MANAGEMENT
   */
  setHighlighted(highlighted, reason = 'manual') {
    this.isHighlighted = highlighted;
    this.highlightReason = reason;

    this.log(
      `${highlighted ? '🔆' : '🔅'} Rândul ${this.id} ${highlighted ? 'evidențiat' : 'ne-evidențiat'} (${reason})`
    );
  }

  /**
   * 👁️ VISIBILITY MANAGEMENT
   */
  setVisible(visible) {
    this.isVisible = visible;
    this.log(`${visible ? '👁️' : '🙈'} Rândul ${this.id} ${visible ? 'vizibil' : 'ascuns'}`);
  }

  /**
   * 📊 CLICK TRACKING
   */
  registerClick() {
    this.clickCount++;
    this.lastClickTime = Date.now();
    this.log(`🖱️ Click pe rândul ${this.id} (total: ${this.clickCount})`);
  }

  /**
   * 🔄 DATA MANAGEMENT
   */
  resetToOriginal() {
    this.data = Object.fromEntries(
      Object.entries(this.originalData).filter(([key]) => key !== 'Id')
    );

    this.isModified = false;
    this.modifiedCells.clear();

    // Reset celule la valorile originale
    this.cells.forEach((cell, columnId) => {
      cell.value = cell.originalValue;
      cell.displayValue = cell.originalValue;
      cell.isModified = false;
    });

    this.log(`🔄 Rândul ${this.id} resetat la valorile originale`);
  }

  getModifiedCells() {
    const modified = {};
    this.modifiedCells.forEach((columnId) => {
      const cell = this.cells.get(columnId);
      if (cell && cell.isModified) {
        modified[columnId] = {
          oldValue: cell.originalValue,
          newValue: cell.value,
        };
      }
    });
    return modified;
  }

  hasModifications() {
    return this.modifiedCells.size > 0;
  }

  /**
   * 🎨 STYLING MANAGEMENT
   */
  setRowStyling(styling) {
    this.backgroundColor = styling.backgroundColor || this.backgroundColor;
    this.textColor = styling.textColor || this.textColor;
    this.customCssClass = styling.cssClass || this.customCssClass;

    this.log(`🎨 Styling aplicat pentru rândul ${this.id}`);
  }

  getRowStyling() {
    return {
      backgroundColor: this.backgroundColor,
      textColor: this.textColor,
      customCssClass: this.customCssClass,
    };
  }

  /**
   * 📈 METRICS ȘI STATISTICI
   */
  getMetrics() {
    return {
      id: this.id,
      index: this.index,
      clickCount: this.clickCount,
      selectCount: this.selectCount,
      lastClickTime: this.lastClickTime,
      totalHoverTime: this.hoverTime,
      isCurrentlyHovered: this.isHovered,
      isSelected: this.isSelected,
      isHighlighted: this.isHighlighted,
      isVisible: this.isVisible,
      isModified: this.isModified,
      modifiedCellsCount: this.modifiedCells.size,
      totalCells: this.cells.size,
    };
  }

  /**
   * 🔧 SYNC CU GLOBAL STATE (pentru compatibilitate)
   */
  syncToGlobalState() {
    // Sync cu selectedRows global
    if (this.isSelected) {
      if (!window.selectedRows) window.selectedRows = new Set();
      window.selectedRows.add(this.index);
    } else {
      if (window.selectedRows) {
        window.selectedRows.delete(this.index);
      }
    }

    // Sync cu highlighted rows
    if (this.isHighlighted) {
      if (!window.highlightedRows) window.highlightedRows = new Set();
      window.highlightedRows.add(this.id);
    }
  }

  syncFromGlobalState() {
    // Sync selecție
    if (window.selectedRows && window.selectedRows.has(this.index)) {
      this.isSelected = true;
    }

    // Sync highlighting
    if (window.highlightedRows && window.highlightedRows.has(this.id)) {
      this.isHighlighted = true;
    }
  }

  /**
   * 🔧 UTILITY METHODS - Actualizate pentru structura cu ID-uri numerice
   */
  getAllCellValues() {
    const values = {};
    this.cells.forEach((cell, columnId) => {
      values[columnId] = cell.value;
    });
    return values;
  }

  /**
   * 🔧 RETURNEAZĂ DATELE ÎN FORMATUL ORIGINAL PENTRU COMPATIBILITATE
   */
  getOriginalFormatData() {
    const originalFormat = {};
    this.cells.forEach((cell, columnId) => {
      if (cell.originalCellObject) {
        // Dacă avem obiectul original, îl folosim
        originalFormat[columnId] = {
          ...cell.originalCellObject,
          value: cell.value, // dar cu valoarea actualizată
        };
      } else {
        // Fallback pentru celule fără formatare
        originalFormat[columnId] = {
          back_color: cell.backgroundColor,
          fore_color: cell.textColor,
          font_bold: cell.fontWeight === 'bold',
          font_italic: cell.fontStyle === 'italic',
          font_underline: cell.textDecoration === 'underline',
          value: cell.value,
        };
      }
    });
    return originalFormat;
  }

  /**
   * 🔧 OBȚINE VALOAREA PENTRU O COLOANĂ SPECIFICĂ (cu fallback)
   */
  getValueForColumn(columnId) {
    // Convertește columnId la string dacă e număr
    const keyToFind = String(columnId);
    const cell = this.cells.get(keyToFind);
    return cell ? cell.value : null;
  }

  /**
   * 🔧 VERIFICĂ DACĂ RÂNDUL CONȚINE O ANUMITĂ COLOANĂ
   */
  hasColumn(columnId) {
    return this.cells.has(String(columnId));
  }

  /**
   * 🔧 OBȚINE TOATE ID-URILE DE COLOANE DIN ACEST RÂND
   */
  getColumnIds() {
    return Array.from(this.cells.keys());
  }

  getCellsWithFormatting() {
    const formatted = {};
    this.cells.forEach((cell, columnId) => {
      if (cell.hasCustomFormatting) {
        formatted[columnId] = {
          value: cell.value,
          formatting: {
            backgroundColor: cell.backgroundColor,
            textColor: cell.textColor,
            fontWeight: cell.fontWeight,
            fontStyle: cell.fontStyle,
            textDecoration: cell.textDecoration,
          },
        };
      }
    });
    return formatted;
  }

  /**
   * 🔍 SEARCH ȘI FILTERING
   */
  matchesSearchTerm(searchTerm, searchColumns = null) {
    if (!searchTerm) return true;

    const term = searchTerm.toLowerCase();
    const columnsToSearch = searchColumns || Array.from(this.cells.keys());

    return columnsToSearch.some((columnId) => {
      const cell = this.cells.get(columnId);
      if (!cell) return false;

      const value = String(cell.displayValue || cell.value || '').toLowerCase();
      return value.includes(term);
    });
  }

  /**
   * 📊 DEBUGGING ȘI LOGGING
   */
  log(message) {
    console.log(`%c[Row ${this.id}] ${message}`, 'color: #10b981');
  }

  /**
   * 📊 DEBUG INFO COMPLETĂ - Adaptată pentru structura cu ID-uri numerice
   */
  getDebugInfo() {
    const columnIds = this.getColumnIds();
    const sampleCell = columnIds.length > 0 ? this.cells.get(columnIds[0]) : null;

    return {
      basic: {
        id: this.id,
        index: this.index,
        isVisible: this.isVisible,
        isSelected: this.isSelected,
        isHighlighted: this.isHighlighted,
        isModified: this.isModified,
      },
      cells: {
        total: this.cells.size,
        modified: this.modifiedCells.size,
        withFormatting: Array.from(this.cells.values()).filter((c) => c.hasCustomFormatting).length,
        columnIds: columnIds,
        sampleCellData: sampleCell,
      },
      metrics: this.getMetrics(),
      data: {
        originalColumnIds: Object.keys(
          Object.fromEntries(Object.entries(this.originalData).filter(([key]) => key !== 'Id'))
        ),
        currentColumnIds: columnIds,
        modifiedCells: Array.from(this.modifiedCells),
      },
    };
  }

  /**
   * 📊 DEMO PENTRU DEBUGGING - Afișează structura completă
   */
  debugShowStructure() {
    console.group(`🔍 ROW ${this.id} - Structură completă`);

    console.log('📊 Date de bază:', {
      id: this.id,
      index: this.index,
      totalCells: this.cells.size,
    });

    console.log('🎯 Stări:', {
      isSelected: this.isSelected,
      isHighlighted: this.isHighlighted,
      isModified: this.isModified,
      isVisible: this.isVisible,
    });

    console.log('📈 Metrics:', this.getMetrics());

    console.group('🔧 Celule individuale:');
    this.cells.forEach((cell, columnId) => {
      console.log(`Coloana ${columnId}:`, {
        value: cell.value,
        hasFormatting: cell.hasCustomFormatting,
        backgroundColor: cell.backgroundColor,
        textColor: cell.textColor,
        isModified: cell.isModified,
      });
    });
    console.groupEnd();

    console.groupEnd();
  }
}

// Export pentru module
export default Row;
