Species.SearchFormView = Ember.View.extend
  templateName: 'species/search_form'
  classNames: ['search-block']
  didInsertElement: ->
    @get('controller').send('ensureGeoEntitiesLoaded')