Species.DownloadsForEuListingsController = Ember.Controller.extend
  needs: ['geoEntities']
  designation: 'eu'
  appendices: ['A', 'B', 'C', 'D']
  selectedAppendices: []
  selectedGeoEntities: []
  selectedTaxonConcepts: []

