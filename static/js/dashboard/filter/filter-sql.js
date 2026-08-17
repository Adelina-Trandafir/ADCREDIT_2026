/**
 * 🔧 FILTER SQL MIXIN
 * Pure functions pentru generarea SQL (din filter-core.js)
 *
 * RESPONSABILITĂȚI:
 * ✅ SQL generation pentru toate tipurile de filtre
 * ✅ Validare configurații filtre
 * ✅ Escaping SQL pentru siguranță
 * ✅ Combinare filtre multiple
 * ✅ Optimizări query
 *
 * NOTE:
 * - DOAR pure functions (fără state)
 * - Fără event handling
 * - Thread-safe operations
 * - SQL injection protection
 *
 * @version 4.0.0
 */

export const filterSQLMixin = {
  /**
   * 🔧 MAKE FILTER DATA (helper pentru construire config)
   */
  makeFilterData(reason = '') {
    let filterType = '';
    let filterData = null;

    if (reason === 'clear') {
      filterData = {
        field: '',
        operator: '',
        value: '',
        type: '',
        id: this.currentColumn.id,
      };
    } else if (reason === 'search') {
      const value = this.exactCombobox?.getInputValue();
      if (value) {
        filterData = {
          field: this.currentColumn.field,
          operator: value.startsWith('*') ? 'LIKE' : 'starts_with',
          value: value,
          type: 'partial',
          id: this.currentColumn.id,
        };
      }
    } else if (reason === 'init' || reason === 'selected') {
      Object.values(this.optionButtons).forEach((radio) => {
        if (radio.checked) filterType = radio.value;
      });

      try {
        if (filterType === 'exact') {
          const value = this.exactCombobox?.getSelectedValue();
          if (value) {
            filterData = {
              field: this.currentColumn.PK,
              operator: '=',
              value: this.cbxSelectedValue,
              type: 'exact',
              id: this.currentColumn.id,
            };
          }
        } else if (filterType === 'partial') {
          if (this.partialTextElement.value) {
            filterData = {
              field: this.currentColumn.field,
              operator: 'LIKE',
              value: this.partialTextElement.value,
              type: 'partial',
              id: this.currentColumn.id,
            };
          }
        } else if (filterType === 'range') {
          if (this.rangeFromElement.value || this.rangeToElement.value) {
            filterData = {
              field: this.currentColumn.field,
              operator: 'BETWEEN',
              value: {
                from: this.rangeFromElement.value,
                to: this.rangeToElement.value,
              },
              type: 'range',
              id: this.currentColumn.id,
            };
          }
        }
      } catch (error) {
        this.handleError('Eroare la aplicarea filtrului', error);
        return;
      }
    } else {
      this.log.error('Nu ai specificat un reason! Nu pot sa construiesc {filterData}!');
    }

    return filterData;
  },

  /**
   * 🔧 GENERARE FILTRU SQL
   */
  generateFilterSQL(filterConfig) {
    const { field, operator, value, type } = filterConfig;
    const escapedField = this.escapeFieldName(field);
    const escapedValue = this.escapeValue(value, type);

    switch (operator.toLowerCase()) {
      case 'equals':
      case '=':
        return `${escapedField} = ${escapedValue}`;

      case 'not_equals':
      case '!=':
        return `${escapedField} != ${escapedValue}`;

      case 'contains':
      case 'like':
        return `${escapedField} LIKE '%${this.escapeLikeValue(value)}%'`;

      case 'not_contains':
      case 'not_like':
        return `${escapedField} NOT LIKE '%${this.escapeLikeValue(value)}%'`;

      case 'starts_with':
        return `${escapedField} LIKE '${this.escapeLikeValue(value)}%'`;

      case 'ends_with':
        return `${escapedField} LIKE '%${this.escapeLikeValue(value)}'`;

      case 'greater_than':
      case '>':
        return `${escapedField} > ${escapedValue}`;

      case 'greater_equal':
      case '>=':
        return `${escapedField} >= ${escapedValue}`;

      case 'less_than':
      case '<':
        return `${escapedField} < ${escapedValue}`;

      case 'less_equal':
      case '<=':
        return `${escapedField} <= ${escapedValue}`;

      case 'between':
        if (Array.isArray(value) && value.length === 2) {
          const val1 = this.escapeValue(value[0], type);
          const val2 = this.escapeValue(value[1], type);
          return `${escapedField} BETWEEN ${val1} AND ${val2}`;
        }
        return '';

      case 'in':
        if (Array.isArray(value) && value.length > 0) {
          const escapedValues = value.map((v) => this.escapeValue(v, type)).join(', ');
          return `${escapedField} IN (${escapedValues})`;
        }
        return '';

      case 'not_in':
        if (Array.isArray(value) && value.length > 0) {
          const escapedValues = value.map((v) => this.escapeValue(v, type)).join(', ');
          return `${escapedField} NOT IN (${escapedValues})`;
        }
        return '';

      case 'is_null':
        return `${escapedField} IS NULL`;

      case 'is_not_null':
        return `${escapedField} IS NOT NULL`;

      case 'is_empty':
        return `(${escapedField} IS NULL OR ${escapedField} = '')`;

      case 'is_not_empty':
        return `(${escapedField} IS NOT NULL AND ${escapedField} != '')`;

      default:
        this.log?.error?.(`⚠️ Operator necunoscut: ${operator}`);
        return '';
    }
  },

  /**
   * 🔗 COMBINARE FILTRE MULTIPLE
   */
  combineFilters(filters, logicalOperator = 'AND') {
    if (!Array.isArray(filters) || filters.length === 0) {
      return '';
    }

    const validFilters = filters
      .map((filter) => this.generateFilterSQL(filter))
      .filter((sql) => sql.trim() !== '');

    if (validFilters.length === 0) {
      return '';
    }

    if (validFilters.length === 1) {
      return validFilters[0];
    }

    const operator = logicalOperator.toUpperCase() === 'OR' ? ' OR ' : ' AND ';
    return `(${validFilters.join(operator)})`;
  },

  /**
   * 📊 GENERARE SQL COMPLET (toate filtrele active)
   */
  generateCompleteFilterSQL(activeFilters, globalOperator = 'AND') {
    if (!activeFilters || typeof activeFilters !== 'object') {
      return '';
    }

    const filterArray = Object.values(activeFilters).filter(
      (filter) => filter && this.validateFilterConfig(filter)
    );

    if (filterArray.length === 0) {
      return '';
    }

    return this.combineFilters(filterArray, globalOperator);
  },

  /**
   * ✅ VALIDARE CONFIGURAȚIE FILTRU
   */
  validateFilterConfig(filterConfig) {
    if (!filterConfig || typeof filterConfig !== 'object') {
      return false;
    }

    const { field, operator, value } = filterConfig;

    // Field obligatoriu și non-empty
    if (!field || typeof field !== 'string' || field.trim() === '') {
      return false;
    }

    // Operator obligatoriu și valid
    if (!operator || typeof operator !== 'string') {
      return false;
    }

    // Value poate fi null pentru operatori is_null, is_not_null
    const nullValueOperators = ['is_null', 'is_not_null'];
    if (
      !nullValueOperators.includes(operator.toLowerCase()) &&
      (value === undefined || value === null)
    ) {
      return false;
    }

    // Validare specifică pentru operatori array
    const arrayOperators = ['between', 'in', 'not_in'];
    if (arrayOperators.includes(operator.toLowerCase()) && !Array.isArray(value)) {
      return false;
    }

    return true;
  },

  /**
   * 🛡️ ESCAPE FIELD NAME
   */
  escapeFieldName(fieldName) {
    if (!fieldName || typeof fieldName !== 'string') {
      return '';
    }

    // Elimină caractere periculoase și păstrează doar alfanumerice + underscore
    return fieldName.replace(/[^a-zA-Z0-9_]/g, '');
  },

  /**
   * 🛡️ ESCAPE VALUE (cu type checking)
   */
  escapeValue(value, type = 'text') {
    if (value === null || value === undefined) {
      return 'NULL';
    }

    switch (type.toLowerCase()) {
      case 'number':
      case 'integer':
      case 'float':
      case 'decimal':
        const numValue = parseFloat(value);
        return isNaN(numValue) ? '0' : numValue.toString();

      case 'boolean':
        return value ? '1' : '0';

      case 'date':
      case 'datetime':
      case 'timestamp':
        return `'${this.escapeStringValue(value.toString())}'`;

      case 'text':
      case 'string':
      default:
        return `'${this.escapeStringValue(value.toString())}'`;
    }
  },

  /**
   * 🛡️ ESCAPE STRING VALUE (SQL injection protection)
   */
  escapeStringValue(str) {
    if (typeof str !== 'string') {
      return '';
    }

    return str
      .replace(/\\/g, '\\\\') // Escape backslash
      .replace(/'/g, "''") // Escape single quotes
      .replace(/"/g, '\\"') // Escape double quotes
      .replace(/\x00/g, '\\0') // Escape NULL
      .replace(/\n/g, '\\n') // Escape newline
      .replace(/\r/g, '\\r') // Escape carriage return
      .replace(/\x1a/g, '\\Z'); // Escape ctrl+Z
  },

  /**
   * 🛡️ ESCAPE LIKE VALUE (LIKE wildcard protection)
   */
  escapeLikeValue(value) {
    if (typeof value !== 'string') {
      return '';
    }

    return this.escapeStringValue(value)
      .replace(/%/g, '\\%') // Escape LIKE wildcard %
      .replace(/_/g, '\\_'); // Escape LIKE wildcard _
  },

  /**
   * ⚡ OPTIMIZARE SQL
   */
  optimizeFilterSQL(sql) {
    if (!sql || typeof sql !== 'string') {
      return '';
    }

    let optimized = sql
      // Elimină spații multiple
      .replace(/\s+/g, ' ')
      // Elimină paranteze inutile pentru un singur filtru
      .replace(/^\(\s*([^()]+)\s*\)$/, '$1')
      // Elimină AND/OR de la început sau sfârșit
      .replace(/^\s*(AND|OR)\s+/i, '')
      .replace(/\s+(AND|OR)\s*$/i, '')
      // Trim final
      .trim();

    return optimized;
  },

  /**
   * ✅ VALIDARE SQL
   */
  isValidSQL(sql) {
    if (!sql || typeof sql !== 'string') {
      return false;
    }

    // Verificări de bază pentru SQL malformat
    const invalidPatterns = [
      /['"]\s*;\s*['"]/, // Possible SQL injection
      /--/, // SQL comments
      /\/\*/, // SQL multi-line comments
      /\bDROP\b/i, // DROP statements
      /\bDELETE\b/i, // DELETE statements
      /\bINSERT\b/i, // INSERT statements
      /\bUPDATE\b/i, // UPDATE statements
      /\bCREATE\b/i, // CREATE statements
      /\bALTER\b/i, // ALTER statements
      /\bEXEC\b/i, // EXEC statements
    ];

    return !invalidPatterns.some((pattern) => pattern.test(sql));
  },

  /**
   * 📊 ANALIZĂ SQL (pentru debugging - opțional)
   */
  analyzeFilterSQL(sql) {
    if (!sql || typeof sql !== 'string') {
      return {
        isEmpty: true,
        filterCount: 0,
        operators: [],
        fields: [],
        complexity: 'none',
      };
    }

    const operators = [];
    const fields = [];

    // Extrage operatori
    const operatorMatches = sql.match(
      /\b(=|!=|>|>=|<|<=|LIKE|NOT LIKE|IN|NOT IN|BETWEEN|IS NULL|IS NOT NULL)\b/gi
    );
    if (operatorMatches) {
      operators.push(...operatorMatches.map((op) => op.toUpperCase()));
    }

    // Extrage field names
    const fieldMatches = sql.match(/\b[a-zA-Z_][a-zA-Z0-9_]*\b(?=\s*[=!><]|\s+LIKE|\s+IN|\s+IS)/g);
    if (fieldMatches) {
      fields.push(...fieldMatches);
    }

    // Calculează complexitatea
    let complexity = 'simple';
    if (operators.length > 3) complexity = 'complex';
    else if (operators.length > 1) complexity = 'medium';

    return {
      isEmpty: false,
      filterCount: operators.length,
      operators: [...new Set(operators)],
      fields: [...new Set(fields)],
      complexity,
      length: sql.length,
      hasLogicalOperators: /\b(AND|OR)\b/i.test(sql),
    };
  },
};
