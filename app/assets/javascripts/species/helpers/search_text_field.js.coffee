#
# * An extended TextField for use in scientific name search.
# *
# * Handles text change events and creates an autocomplete box for the text.
# 

# Possible typehead alternatives:
# https://github.com/tcrosen/twitter-bootstrap-typeahead/tree/2.0
# https://github.com/twitter/typeahead.js

Species.SearchTextField = Ember.TextField.extend(

  value: ""
  attributeBindings: ["autocomplete"]

  keyUp: (event) ->
    searchFormController = @get "controller"
    searchFormController.set "scientific_name", $(event.target).val()
    
  click: (event) ->
    self = @
    if $(".typeahead").length <= 0
      $("#scientific_name").typeahead
        minLength: 3
        source: (query, process) ->
          $.get "/api/v1/taxon_concepts/autocomplete",
            scientific_name: query
            rank_name: query
            full_name: query 
            limit: 10
          , (data) ->
            labels = self.parser data.taxon_concepts
            process(labels)
        sorter: self.sorter
        matcher: self.matcher
        updater: self.updater
        highlighter: self.highlighter
    @$().val ""  if @$().val() is @get("placeholder")
    @$().attr "placeholder", ""

  focusOut: (event) ->
    @$().val @get("placeholder")  if @$().val().length is 0  if $.browser.msie
    @$().attr "placeholder", @get("placeholder")

  updater: (item) ->
    # Remove synonyms when an item is selected
    item.replace /(.*)( \(\=.*\))/, "$1"

  highlighter: (item) ->
    query = @query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, "\\$&")
    transform = ($1, match) ->
      "<span style=\"text-decoration:underline\">" + match + "</span>"

    item.replace(new RegExp("^(" + query + ")", "i"), transform)
      .replace new RegExp("=(" + query + ")", "ig"), transform

  matcher: (item) ->
    true

  sorter: (items) ->
    items

  # This parser relies on a Hack inside bootstrap-typeahead.
  # If a string in the list starts with an underscore it is treated as
  # header in the autocomplete list.
  # TODO: any better alternatives? 
  parser: (data) ->
    results = []
    # Extract the names of each result row for use by typeahead.js
    _.each data, (el, idx) ->
      unless "_#{el.rank_name}" in results
        results.push "_#{el.rank_name}"
      entry = el.full_name
      if el.matching_names.length > 0
        entry += " (=" + el.matching_names.join(", ") + ")"
      results.push entry
    results

  # A better way to prepare the data, but unfortunately not compatible 
  # with boostrap-typehead
  #parserB: (data) ->
  #  content = data
  #  results = {}
  #  # Extract the names of each result row for use by typeahead.js
  #  content.forEach (item, i) ->
  #    results[item.rank_name] = []  unless item.rank_name of results
  #    entry = item.full_name
  #    if el.matching_names.length > 0
  #      entry += " (=" + el.matching_names.join(", ") + ")"
  #    results[item.rank_name].push entry
  #  results

  didInsertElement: ->
    @$().val @$().attr("placeholder")  if $.browser.msie


)
