Species.DownloadsForCitesListingsController = Ember.Controller.extend
  needs: ['geoEntities']
  designation: 'cites'
  appendices: ['I', 'II', 'III']
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