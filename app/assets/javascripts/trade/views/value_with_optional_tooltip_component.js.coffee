Trade.ValueWithOptionalTooltipComponent = Ember.Component.extend
  tagName: 'span'
  classNameBindings: ['hasTooltip:has-tooltip']
  attributeBindings: ['longDisplayValue:data-original-title']
  layout: Ember.Handlebars.compile('{{displayValue}}')

  init: () ->
    this._super()
    # it is not obvious to me why I need to manually establish a binding here
    # but otherwise the component would not update the value
    Ember.bind(@, 'displayValue', 'content.' + @get('displayProperty'))

  displayValue: null
  longDisplayValue: ( ->
    if @get('longDisplayProperty') != undefined
      @get('content').get(@get('longDisplayProperty'))
    else
      null
  ).property('longDisplayProporty', 'displayValue').volatile()

  hasTooltip: ( ->
    @get('longDisplayValue') != null
  ).property('longDisplayValue')
