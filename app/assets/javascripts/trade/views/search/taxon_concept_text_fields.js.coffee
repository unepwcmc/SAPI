Trade.TaxonConceptTextFieldsView = Ember.View.extend
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
