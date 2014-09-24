Trade.MultiSelect = Ember.View.extend
  tagName: 'div'
  classNames: ['popup-area']
  allValues: null
  selectedValues: null
  selectedValuesCollectionName: 'options'
  selectedValueDisplayProperty: 'name'

  layoutName: 'trade/shipments_common/multi_select'

  click: ->
    wasVisible = @.$('.popup-holder01').is(':visible')
    $('.popup-holder01').hide()
    unless wasVisible
      @.$('.popup-holder01').show()

Trade.MultiSelectButton = Ember.View.extend
  tagName: 'a'
  href: '#'
  classNames: ['link']
  selectedValues: null
  selectedValuesCollectionName: 'options'
  selectedValueDisplayProperty: 'name'

  template: Ember.Handlebars.compile("{{view.summary}}")

  summary: ( ->
    if (@get('selectedValues').length == 0)
      msg = if @get('blankValue') == true
        'Blank '
      else
        'All '
      msg += @get('selectedValuesCollectionName')
    else if (@get('selectedValues').length == 1)
      msg = @get('selectedValues')[0].get(
        @get('selectedValueDisplayProperty')
      )
      msg += ' or blank' if @get('blankValue') == true
    else
      msg = @get('selectedValues').length + " " +
      @get('selectedValuesCollectionName') + " selected"
      msg += ' or blank' if @get('blankValue') == true
    msg
  ).property("selectedValues.@each", 'blankValue')

Trade.MultiSelectDropdown = Ember.View.extend
  layoutName: 'trade/shipments_common/multi_select_dropdown'
  classNames: ['popup-holder01']
  allValues: null
  selectedValues: null

  hasAutoComplete: ( ->
    @get('query') != undefined
  ).property()

  hasGroupedOptions: ( ->
    @get('allValuesGrouped') != undefined
  ).property()

  hasBlankValue: ( ->
    @get('blankValue') != undefined
  ).property()

  click: (e) ->
    e.stopPropagation();

Trade.MultiSelectSelectedValuesCollectionView = Ember.CollectionView.extend
  tagName: 'ul'
  content: null
  selectedValueDisplayProperty: 'name'
  selectedValueShortDisplayProperty: null

  itemViewClass: Ember.View.extend
    contextBinding: 'content'
    displayName: ( ->
      if @get('parentView.selectedValueShortDisplayProperty')
        @get('content.' + @get('parentView.selectedValueShortDisplayProperty'))
      else
        @get('content.' + @get('parentView.selectedValueDisplayProperty'))
    ).property(
      'parentView.selectedValueShortDisplayProperty',
      'parentView.selectedValueDisplayProperty'
    )
    longDisplayName: ( ->
      @get('content.' + @get('parentView.selectedValueDisplayProperty'))
    ).property('parentView.selectedValueDisplayProperty')
    template: Ember.Handlebars.compile(
      '<span title="{{view.longDisplayName}}">{{view.displayName}}</span>' +
      '<a {{action "deleteSelection" this target="view.parentView"}} class="delete">x</a>'
    )

  actions:
    deleteSelection: (context) ->
      @get('content').removeObject(context)

Trade.MultiSelectAllValuesCollectionView = Ember.CollectionView.extend
  tagName: 'ul'
  content: null
  selectedValues: null
  selectedValueDisplayProperty: 'name'

  itemViewClass: Ember.View.extend
    contextBinding: 'content'
    displayName: ( ->
      @get('content.' + @get('parentView.selectedValueDisplayProperty'))
    ).property('parentView.selectedValueDisplayProperty')
    template: Ember.Handlebars.compile('{{view.displayName}}')

    click: (event) ->
      @get('parentView.selectedValues').addObject(@get('context'))

Trade.MultiSelectSearchTextField = Em.TextField.extend
  value: ''

  attributeBindings: ['autocomplete']

  click: (e) ->
    @.$().select()

  keyUp: (event) ->
    Ember.run.cancel(@currentTimeout)
    @currentTimeout = Ember.run.later(@, ->
      @set('query', @get('value'))
    , 300)

Trade.TaxonConceptAutoCompleteSuggestionView = Ember.View.extend
  tagName: 'li'
  content: null
  contextBinding: 'content'
  selectedValues: null
  template: ( ->
    Ember.Handlebars.compile(
      '{{#highlight view.content.autoCompleteSuggestion query=view.query}}
        {{unbound view.content}}
      {{/highlight}}'
    )
  ).property()

  click: (event) ->
    @get('selectedValues').addObject(@get('context'))