Species.DownloadsForCmsListingsController = Ember.Controller.extend
  needs: ['geoEntities']
  designation: 'cms'
  appendices: ['I', 'II']
  selectedAppendices: []
  selectedGeoEntities: []
  selectedTaxonConcepts: []

