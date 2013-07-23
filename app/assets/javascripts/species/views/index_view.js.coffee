Species.IndexView = Ember.View.extend
  templateName: 'species/index'
  # this is how you set the container's id
  init: () ->
    @.set('elementId', 'main')
    return @._super()
  didInsertElement: () ->
    $('body').removeClass('inner')
