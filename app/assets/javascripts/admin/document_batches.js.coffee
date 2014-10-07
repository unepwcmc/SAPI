$(document).ready ->

  populateFormForEachFile = (evt) ->
    $('#document-form-collection').empty()
    files = evt.target.files
    $.each(files, (idx, f) ->
      templateClone = $('#document-form-template').clone()
      templateClone.removeClass('hidden')
      templateClone.addClass('document-form')
      templateClone.find('.file-name').html(f.name)
      templateClone.find('select').attr(
        'name',
        'document_batch[documents_attributes][' + idx + '][type]'
      )
      $('#document-form-collection').append(templateClone)
    )

  # Check for the various File API support.
  if (window.File && window.FileReader && window.FileList && window.Blob)
    $('#file-upload').change(populateFormForEachFile)
  else
    alert('The File APIs are not fully supported in this browser.')
