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

# The recent-imports block, refreshed on its own while a job runs.
#
# Reloading the page would be simpler, but it throws away a half-filled upload
# form - and a chosen file cannot be put back afterwards, because no browser
# lets script set a file input. Swapping one block leaves the form alone.
#
# Only this block is refreshed, so the counts above it stay as they were until
# the page is loaded again; when the last job finishes, the block says so.
POLL_MS = 5000

running = ($imports) -> $imports.data('running') is true

refreshImports = ($imports) ->
  $.get($imports.data('refresh-url'))
    .done (html) ->
      # Filtered to the block itself rather than used whole: the response does
      # not begin with the element. In development Rails prefixes a partial
      # with an HTML comment naming the template, and there is a leading
      # newline either way, so the first parsed node is a comment or text.
      # Reading data('running') off that gives undefined, which reads as
      # nothing running and stops the poll after a single tick.
      $next = $($.parseHTML(html)).filter('#taxon-mapping-imports')

      return finished($imports) unless $next.length

      $imports.replaceWith($next)
      # The rows that just arrived carry their timestamps as UTC for the
      # browser to restyle, exactly as the server-rendered ones did.
      showLocalTimes()
      if running($next) then pollImports($next) else finished($next)
    # A failed poll stops it. The block is already showing something true, and
    # retrying into a dead server would only fill the console.
    .fail -> $imports.find('.js-imports-polling').text('refresh failed - reload the page')

pollImports = ($imports) -> setTimeout((-> refreshImports($imports)), POLL_MS)

finished = ($imports) ->
  $imports.find('.js-imports-polling')
    .text('finished - reload the page to update the counts above')

# The pairs holding nothing are rendered but hidden: six taxonomies make
# fifteen pairs and most are usually empty, so showing them all buries the few
# that matter. They are worth keeping though - a blank row is the only thing
# that shows a lookup will come back empty because nobody uploaded that file.
toggleEmptyPairs = ($button) ->
  $rows = $('.js-empty-pair')
  showing = $rows.first().is(':hidden')

  $rows.toggle(showing)
  count = $button.data('hidden-count')
  $button.text("#{if showing then 'Hide' else 'Show'} #{count} " +
    "#{if count is 1 then 'pair' else 'pairs'} with nothing loaded")

$(document).ready ->
  showLocalTimes()

  $(document).on 'click', '.js-toggle-empty-pairs', -> toggleEmptyPairs($(@))

  $form = $('#taxon-mapping-upload')
  new TaxonMappingUpload($form).init() if $form.length

  $imports = $('#taxon-mapping-imports')
  pollImports($imports) if $imports.length and running($imports)
