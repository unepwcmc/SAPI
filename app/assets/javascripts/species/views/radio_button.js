Ember.RadioButton = Ember.View.extend({
  title: null,
  checked: false,
  group: "radio_button",
  disabled: false,

  classNames: ['ember-radio-button'],

  defaultTemplate: Ember.Handlebars.compile('<label><input type="radio" {{ bindAttr disabled="view.disabled" name="view.group" value="view.option" checked="view.checked"}} />{{view.title}}</label>'),

  bindingChanged: function(){
    console.log('binding changed')
    console.log(this);
   if(this.get("option") == Ember.get(this, 'value')){
       this.set("checked", true);
    }
  }.observes("value"),

  change: function() {
    console.log('change')
    console.log(this)
    Ember.run.once(this, this._updateElementValue);
  },

  _updateElementValue: function() {
    console.log('update value');
    var input = this.$('input:radio');
    Ember.set(this, 'value', input.attr('value'));
    console.log(this.value);
  }
});
