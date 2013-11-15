Trade.MultiSelect = Ember.View.extend
  tagName: 'div'
  classNames: ['popup-area']
  allValues: null
  selectedValues: null
  selectedValuesCollectionName: 'options'
  selectedValueDisplayProperty: 'name'

  templateName: 'trade/shipments/multi_select'

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
      return "You haven't selected any " +
        @get('selectedValuesCollectionName') + " yet"
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
