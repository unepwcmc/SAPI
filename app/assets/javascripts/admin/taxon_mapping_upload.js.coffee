# Block A of the Taxon Mapping page, plus Block D's refresh.
#
# The form works without any of this. It hides the second taxonomy select when
# the upload does not need one, says how far a large file has got, and brings
# the page back while an import is still running. What the upload acts on is
# whatever is selected - nothing here guesses at it.

class TaxonMappingUpload
  constructor: (@$form) ->
    @$far = @$form.find('#upload_foreign_matchable_taxonomy_id')
    @$farGroup = @$form.find('.js-far-group')
    @$nearLabel = @$form.find('.js-near-label')
    @$nearHint = @$form.find('.js-near-hint')
    @$progress = @$form.find('.js-upload-progress')

  init: ->
    @$form.on 'change', 'input[name="upload[kind]"]', => @showKind()
    @trackUpload()
    @showKind()

  matches: -> @$form.find('input[name="upload[kind]"]:checked').val() is 'mapping_matches'

  # A taxa file names one taxonomy, a match file names two. Without this the
  # form always asks for a second one, which means nothing for a taxa upload.
  showKind: ->
    @$farGroup.toggle(@matches())
    @$nearHint.toggle(@matches())
    @$nearLabel.text(if @matches() then 'First taxonomy' else 'Taxonomy')
    @$far.prop('required', @matches())

  # The largest export is around 200 MB, so without this the page looks stuck
  # for the best part of a minute.
  trackUpload: ->
    @$form.on 'direct-upload:progress', (e) =>
      @$progress.text("Uploading #{Math.round(e.originalEvent.detail.progress)}%")
    @$form.on 'direct-upload:error', (e) =>
      e.preventDefault()
      @$progress.text("Upload failed: #{e.originalEvent.detail.error}")

# Server-rendered timestamps are UTC, because the app sets no time zone and the
# people uploading these files are not all in one. The browser is the only party
# that knows the reader's own, so it does the formatting.
showLocalTimes = ->
  $('time[data-local-time]').each ->
    parsed = new Date(@getAttribute('datetime'))
    @textContent = parsed.toLocaleString() unless isNaN(parsed)

$(document).ready ->
  showLocalTimes()

  $form = $('#taxon-mapping-upload')
  new TaxonMappingUpload($form).init() if $form.length

  $imports = $('#taxon-mapping-imports')
  if $imports.length and $imports.data('running') is true
    setTimeout((-> window.location.reload()), 5000)
