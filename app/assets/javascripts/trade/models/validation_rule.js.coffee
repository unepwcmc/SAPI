Trade.ValidationRule = DS.Model.extend
  type: DS.attr('string')
  columnNames: DS.attr('array')
  validValuesView: DS.attr('string')
  formatRe: DS.attr('string')
  createdAt: DS.attr('date')
  updatedAt: DS.attr('date')
