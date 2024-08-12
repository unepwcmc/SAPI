Ember.RadioButton = Ember.View.extend

  tagName : "input"
  type: "radio"
  attributeBindings : [ "name", "type", "value", "checked:checked" ]

  click: ->
    @set("selection", this.$().val())

  checked: (->
    @get("value") == @get("selection")
  ).property()
