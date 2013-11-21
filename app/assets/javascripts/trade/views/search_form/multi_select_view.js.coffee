Trade.MultiSelect = Ember.View.extend
  tagName: 'div'
  classNames: ['popup-area']
  allValues: null
  selectedValues: null
  selectedValuesCollectionName: 'options'
  selectedValueDisplayProperty: 'name'

  templateName: 'trade/shipments/multi_select'

  includeEmptyOption: (->
    if @get('allValues')
      @get('allValues').append('Empty')
  ).property('allValues')

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
      return "All " +
        @get('selectedValuesCollectionName')
    else if (@get('selectedValues').length == 1)
      return @get('selectedValues')[0].get(
        @get('selectedValueDisplayProperty')
      )
    else
      return @get('selectedValues').length + " " +
      @get('selectedValuesCollectionName') + " selected"
  ).property("selectedValues.@each")

Trade.MultiSelectDropdown = Ember.View.extend
  templateName: 'trade/shipments/multi_select_dropdown'
  classNames: ['popup']
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

  click: (event) ->
    if (@.$().val() == @get('placeholder'))
      @.$().val('')
    @.$().attr('placeholder', '')
    @showDropdown()

  focusOut: (event) ->
    @.$().attr('placeholder', @get('placeholder'))
    @hideDropdown() if !@get('parentView.mousedOver')

  keyUp: (event) ->
    @set('value', event.currentTarget.value)
    @showDropdown()

  hideDropdown: () ->
    $('.search fieldset').removeClass('parent-focus parent-active')

  showDropdown: () ->
    if @.$().val().length > 2
      $('.search fieldset').addClass('parent-focus parent-active')

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