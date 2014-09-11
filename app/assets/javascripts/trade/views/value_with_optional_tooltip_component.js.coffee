Trade.ValueWithOptionalTooltipComponent = Ember.Component.extend
  tagName: 'span'
  classNameBindings: ['hasTooltip:has-tooltip']
  attributeBindings: ['longDisplayValue:data-original-title']
  layout: Ember.Handlebars.compile('{{displayValue}}')
  displayValue: ( ->
    @get('content').get(@get('displayProperty'))
  ).property('content.didLoad').volatile()
  longDisplayValue: ( ->
    if @get('longDisplayProperty') != undefined
      @get('content').get(@get('longDisplayProperty'))
    else
      null
  ).property('displayValue')
  hasTooltip: ( ->
    @get('longDisplayValue') != null
  ).property('longDisplayValue')
