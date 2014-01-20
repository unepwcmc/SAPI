Trade.AnnualReportUploadView = Ember.View.extend
  templateName: 'trade/annual_report_upload'

  didInsertElement: ->
    $('label.blank-checkbox').hide()
    # show the enclosing label when checkbox selected
    $('.attribute-area').mouseenter ->
      $(@).find('label.blank-checkbox').show()
    $('.attribute-area').mouseleave ->
      label = $(@).children('label.blank-checkbox').first()
      unless label.children('input[type=checkbox]:checked').length > 0
        label.hide()

