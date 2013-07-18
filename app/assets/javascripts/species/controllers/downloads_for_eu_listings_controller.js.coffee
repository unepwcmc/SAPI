Species.DownloadsForEuListingsController = Ember.Controller.extend
  needs: ['geoEntities']
  designation: 'eu'
  appendices: ['A', 'B', 'C', 'D']
  selectedAppendices: []
  selectedGeoEntities: []
  selectedTaxonConcepts: []

  toParams: ( ->
    {
      data_type: 'Listings'
      filters: 
        designation: @get('designation')
        appendices: @get('selectedAppendices')
    }
  ).property('selectedAppendices.@each')

  downloadUrl: ( ->
    '/exports/download?' + $.param(@get('toParams'))
  ).property('toParams')
