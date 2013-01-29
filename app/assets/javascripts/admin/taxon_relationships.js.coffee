$(document).ready ->
  window.taxonRelationshipForm = new TaxonRelationshipForm()
  window.taxonRelationshipForm.init()
  $("#new-taxon_relationship").delegate "#swap-taxa", "click", (e) ->
    e.preventDefault()
    window.taxonRelationshipForm.swapTaxa()

class TaxonRelationshipForm
  init: () ->
    @initAutocomplete()

  initAutocomplete: () ->
    $(".tr-autocomplete").typeahead
      source: (query, process) =>
        taxonomy_id = $("#taxonomy_id").val()
        $.get('/admin/taxon_concepts/autocomplete',
        {
          scientific_name: query,
          taxonomy_id: taxonomy_id
          limit: 25
        }, (data) =>
          @parentsMap = {}
          labels = []
          $.each(data, (i, item) =>
            label = item.full_name + ' ' + item.rank_name
            @parentsMap[label] = item.id
            labels.push(label)
          )
          return process(labels)
        )
      updater: (item) =>
        if $(this).parents("#left").length > 0
          $("#taxon_relationship_taxon_concept_id").val(@parentsMap[item])
        else
          $("#taxon_relationship_other_taxon_concept_id").val(@parentsMap[item])
          $("#taxon_concept_id").val(@parentsMap[item])
          $("#taxon_concept_id").val(@parentsMap[item])
        return item

  swapTaxa: () ->
    left_elms = $("#left").children(".elements")
    right_elms = $("#right").children(".elements")
    $("#left").append right_elms
    $("#right").append left_elms
    taxon_concept_id = $("#taxon_relationship_taxon_concept_id").val()
    other_taxon_concept_id = $("#taxon_relationship_other_taxon_concept_id").val()
    $("#taxon_relationship_taxon_concept_id").val other_taxon_concept_id
    $("#taxon_relationship_other_taxon_concept_id").val taxon_concept_id
