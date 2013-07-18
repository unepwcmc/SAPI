Species.DownloadsController = Ember.Controller.extend
  needs: ['downloadsForCmsListings', 'downloadsForCitesListings', 'downloadsForEuListings']
  downloadsPopupVisible: false
  downloadsTopButtonVisible: ( ->
    # hide if we're currently showing index
    this.target.get('_activeViews').index == undefined
  ).property()
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

  citesAppendices: ['I', 'II', 'III']