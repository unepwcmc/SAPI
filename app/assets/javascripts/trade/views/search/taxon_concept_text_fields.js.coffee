Trade.TaxonConceptTextFieldsView = Ember.View.extend
  acceptedTaxonInfo: "This is the traded taxon concept that shows up in " +
    "public reports. It gets updated automatically when a reported taxon " +
    "concept is selected, but it is possible to override the automatic " +
    "selection. Updating this field does not affect the selection of " +
    "reported taxon concept."
  reportedTaxonInfo: "This is the traded taxon concept as reported by " +
    "parties. Updating this field will automatically change the selection " +
    "of accepted taxon concept."
  AcceptedSelect2: Trade.TaxonConceptSelect2.extend
    prompt: "Please select taxon names"
  ReportedSelect2: Trade.TaxonConceptSelect2.extend
    prompt: "Please select taxon names"
    includeSynonyms: "true"
    didInsertElement: () ->
      @._super()
      @.$().on('change', (e) =>
        @get('parentView.controller').send('resolveReportedTaxonConcept', e.val)
      )
