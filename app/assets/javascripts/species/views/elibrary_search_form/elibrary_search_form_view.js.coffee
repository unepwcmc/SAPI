Species.ElibrarySearchFormView = Ember.View.extend
  templateName: 'species/elibrary_search_form'
  classNames: ['search-block']
  didInsertElement: ->
    @get('controller').send('ensureGeoEntitiesLoaded')