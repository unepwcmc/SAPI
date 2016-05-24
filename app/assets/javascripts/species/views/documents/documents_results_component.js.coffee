Species.DocumentsResultsComponent = Ember.Component.extend
  layoutName: 'species/components/documents-results'
  tagName: 'tr'
  classNames: ['table-row']

  searchContextInfo: ( ->
    if @get('species')
      "#{@get('searchContext')} search for #{@get('species')}"
    else
      "#{@get('searchContext')} search"
  ).property('searchContext', 'species')

  signedInInfo: ( ->
    'Logged in: ' + if @get('isSignedIn')
      'yes'
    else
      'no'
  ).property('isSignedIn')
