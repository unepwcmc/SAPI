Trade.TaxonConceptSelect2 = Ember.TextField.extend
  attributeBindings: ['required']
  required: true
  width: 'resolve'
  allowClear: true
  closeOnSelect: true
  type: 'hidden'
  origin: null

  didInsertElement: () ->
    placeholderText = this.get('prompt') || ''
    if (!@.$().select2)
      throw new Exception('select2 is required for Trade.TaxonConceptSelect2 control')
    @.$().select2(
      placeholder: placeholderText
      minimumInputLength: 3
      allowClear: this.get('allowClear')
      closeOnSelect: this.get('closeOnSelect')
      dropdownCssClass: 'species_autocomplete'
      initSelection: (element, callback) =>
        @origin = @get('origin')
        value = @get('value')
        # if value is the id
        if typeof(value) is 'number'
          tc = Trade.TaxonConcept.find(value)
          callback({id: tc.get('id'), text: tc.get('fullName')})
        # but value can also be a name
        else
          callback({id: 'init-selection-value', text: value})
      ajax:
        url: "/api/v1/auto_complete_taxon_concepts.json"
        dataType: 'json'
        data: (term, page) ->
          taxon_concept_query: term # search term
          visibility: 'trade'
          per_page: 10
          page: page
        results: (data, page) => # parse the results into the format expected by Select2.
          more = (page * 10) < data.meta.total
          formatted_taxon_concepts = data.auto_complete_taxon_concepts.map (tc) =>
            id: if @origin is 'sandbox' then tc.full_name else tc.id
            text: tc.full_name
          results: formatted_taxon_concepts
          more: more
    )
    # @.$().on('change', (e) ->
    #   console.log(e)
    #   console.log(e.added)
    #   console.log(@get('value'))
    # )

  # observe value and update select2 when changed outside of control
  updateSel2Value: ( ->
    sel2Value = @.$().select2('val')
    actualValue = @get('value')
    if (sel2Value != actualValue || actualValue == '')
      @.$().select2('val', actualValue)
  ).observes('value')

  willDestroyElement: () ->
    @.$().select2('destroy')
