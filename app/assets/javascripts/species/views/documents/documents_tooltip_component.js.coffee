Species.DocumentsTooltipComponent = Ember.Component.extend
  layoutName: 'species/components/documents-tooltip'

  multipleValues: ( ->
    this.get('data').length > 1
  ).property('person')

  formattedData: ( ->
    data = this.get('data')
    dataStr = data.slice(0,40).join(', ')

    if data.length <= 40 then dataStr else dataStr + '...'
  ).property()

  isTaxa: ( ->
    this.get('type') == 'taxa'
  ).property()
