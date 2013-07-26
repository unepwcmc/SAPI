Species.DownloadsController = Ember.Controller.extend
  needs: [
    'downloadsForCmsListings', 
    'downloadsForCitesListings', 'downloadsForCitesRestrictions',
    'downloadsForEuListings', 'downloadsForEuDecisions'
  ]
  downloadsPopupVisible: false
  designation: 'cites'
  designationIsCites: ( ->
    @get('designation') == 'cites'
  ).property('designation')
  designationIsEu: ( ->
    @get('designation') == 'eu'
  ).property('designation')
  designationIsCms: ( ->
    @get('designation') == 'cms'
  ).property('designation')
  citesLegislation: 'listings'
  euLegislation: 'listings'
  legislationIsCitesListings: ( ->
    @get('citesLegislation') == 'listings'
  ).property('citesLegislation')
  legislationIsCitesRestrictions: ( ->
    @get('citesLegislation') == 'restrictions'
  ).property('citesLegislation')
  legislationIsEuListings: ( ->
    @get('euLegislation') == 'listings'
  ).property('euLegislation')
  legislationIsEuDecisions: ( ->
    @get('euLegislation') == 'decisions'
  ).property('euLegislation')

  close: () ->
    @set('downloadsPopupVisible', false)