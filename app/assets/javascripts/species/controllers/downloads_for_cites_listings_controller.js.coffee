Species.DownloadsForCitesListingsController = Ember.Controller.extend
  needs: ['geoEntities']
  designation: 'cites'
  appendices: ['I', 'II', 'III']
  selectedAppendices: []
  selectedGeoEntities: []
  selectedTaxonConcepts: []

