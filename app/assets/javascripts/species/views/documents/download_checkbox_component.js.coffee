Species.DownloadCheckboxComponent = Ember.Component.extend
  layoutName: 'species/components/download-checkbox'
  tagName: 'span'
  downloadAll: false

  watchDownloadAll: ( ->
    component = this
    container = this.$().closest('.inner-table-container')
    $(container).find('.table-body tbody .download-col input').each( ->
      $(this).prop('checked', component.get('downloadAll'))
    )
  ).observes('downloadAll')
