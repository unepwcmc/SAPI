Trade.ValidationRule = DS.Model.extend
  type: DS.attr('string')
  runOrder: DS.attr('number')
  columnNames: DS.attr('array')
  validValuesView: DS.attr('string')
  formatRe: DS.attr('string')
  isPrimary: DS.attr('boolean')
  createdAt: DS.attr('date')
  updatedAt: DS.attr('date')
