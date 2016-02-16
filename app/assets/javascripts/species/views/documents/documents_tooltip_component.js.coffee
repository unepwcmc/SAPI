Species.DocumentsTooltipComponent = Ember.Component.extend
  layoutName: 'species/components/documents-tooltip'

  multipleValues: ( ->
    this.get('data').length > 1
  ).property('person')

  formattedData: ( ->
    this.get('data').join(', ')
  ).property()

  isTaxa: ( ->
    this.get('type') == 'taxa'
  ).property()
