Trade.ApplicationView = Ember.View.extend
  classNames: 'ember-app'
  templateName: 'trade/application'
  currentYear: ( ->
    new Date().getFullYear()
  ).property()
