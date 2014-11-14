Species.DownloadsController = Ember.Controller.extend Species.Spinner,
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
  csvSeparator: $.cookie('speciesplus.csv_separator') 

  showCsvOptions: () ->
    $('#csv_options').show()
    $('.csv_options_holder > a').html('Try changing the option below for .csv outputs:')

  hideCsvOptions: () ->
    $('#csv_options').hide()
    $('.csv_options_holder > a').html('Trouble viewing outputs?')   

  actions:
    close: () ->
      @set('downloadsPopupVisible', false)
      @hideCsvOptions()
      # Closing the spinner cover and resetting the spinner image.
      $(@spinnerSelector).css("visibility", "hidden").find('img').show()

    showHideCsvOptions: () ->
      csvOptions = $('.csv_options')
      if $('#csv_options').is(':visible')
        @hideCsvOptions()
      else
        @showCsvOptions()
