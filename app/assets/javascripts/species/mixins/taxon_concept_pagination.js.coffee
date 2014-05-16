Species.TaxonConceptPagination = Ember.Mixin.create({

  total: ( ->
    @get('content.meta.total')
  ).property('content.isLoaded')

  perPage: ( ->
    parseInt(@get('content.meta.per_page')) || 25
  ).property("content.isLoaded")

  page: ( ->
    parseInt(@get('content.meta.page')) || 1
  ).property("content.isLoaded")

  pages: ( ->
    if @get('total')
      return Math.ceil( @get('total') / @get('perPage'))
    else
      return 1
  ).property('total', 'perPage')

  showPageControls: ( ->
    if @get('pages') > 1 then return yes else return no
  ).property('pages')

  showPrevPage: ( ->
    if @get('page') > 1 then return yes else return no
  ).property('page')

  showNextPage: ( ->
    if @get('page') < @get('pages') then return yes else return no
  ).property('page', 'pages')

})