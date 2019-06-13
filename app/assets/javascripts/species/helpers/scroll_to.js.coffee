Species.ScrollTo = Ember.View.extend
  tagName: 'a'
  attributeBindings: [ "anchor", "label", "title" ]
  classNames: ['hover-pointer']

  title: (->
    'Scroll to ' + @get('label')
  ).property 'label'

  click: (e) ->
    $('html, body').animate { scrollTop: $('#' + @get('anchor')).offset().top }, 500
