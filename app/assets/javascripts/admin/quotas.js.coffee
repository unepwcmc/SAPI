$ ->
  getCount = ->
    $.get "/admin/quotas/count",
      year: $("#quotas_from_year").val()
      included_geo_entities_ids: $("#quotas_included_geo_entities_ids").val()
      excluded_geo_entities_ids: $("#quotas_excluded_geo_entities_ids").val()
      included_taxon_concepts_ids: $("#quotas_included_taxon_concepts_ids").val()
      excluded_taxon_concepts_ids: $("#quotas_excluded_taxon_concepts_ids").val()
    , ((data, textStatus, jqXHR) ->
      $("#quotas-count").text data
      return
    ), "json"
    return

  $("#quotas_from_year").change (e) ->
    getCount()
    return

  $("#quotas_excluded_geo_entities_ids, #quotas_included_geo_entities_ids").on "change", ->
    getCount()
    return

  $("#quotas_excluded_taxon_concepts_ids, #quotas_included_taxon_concepts_ids").select2(
    placeholder: "Select taxon"
    multiple: true
    minimumInputLength: 3
    ajax:
      url: "/admin/taxon_concepts/autocomplete"
      dataType: "json"
      quietMillis: 100
      data: (query) ->
        search_params:
          scientific_name: query
          taxonomy:
            id: 1

        limit: 25

      results: (data) ->
        results = undefined
        results = []
        $.each data, (i, e) ->
          results.push
            id: e.id
            text: e.full_name


        results: results

      dropdownCssClass: "bigdrop"
      placeholder: "Select taxa"
  ).on "change", ->
    getCount()
    return

  $(".toggle-extra-options").click (e) ->
    e.preventDefault()
    $(this).next(".extra-options").toggle()
    $(this).children('span').toggle()
    return
  return

