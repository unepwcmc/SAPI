# What the two taxon mapping uploads happen to have in common. Not a framework
# for imports in general - another kind of upload may need none of this shape,
# and ImportRun deliberately does not impose one.
#
# Both mapping uploads are a zip holding one CSV (or a bare CSV or spreadsheet), replace everything in their
# scope, and have nothing to do afterwards but record what the importer said.
class Imports::MappingJob < ApplicationJob
  # The kinds of upload this family answers to. The imports table is shared -
  # anything using Importer::Base can write to it - so the Taxon Mapping page
  # has to say which rows are its own rather than showing whatever is newest.
  KINDS = %w[mapping_taxa mapping_matches].freeze

  def perform(import_id)
    @import_run = ImportRun.find(import_id)
    # A retry of a job whose upload already ran would replace the scope a
    # second time, so only a pending row is picked up.
    return unless import_run.pending?

    import_run.update!(status: ImportRun::RUNNING, started_at: Time.current)
    result = with_file { |path| load(path) }

    import_run.update!(
      status: result.success? ? ImportRun::DONE : ImportRun::FAILED,
      logs: result.logs,
      finished_at: Time.current
    )
  rescue ActiveRecord::LockWaitTimeout => e
    # The upload page refuses a second upload of a scope already in flight, so
    # reaching here means two slipped through within the same instant. Caught
    # separately because the raw message is about Postgres row locks and says
    # nothing an admin could act on.
    record_failure(e, 'Another import of the same data was already running. Upload this file again.')
    raise
  rescue StandardError => e
    record_failure(e)
    raise
  end

  private

  attr_reader :import_run

  def load(_path)
    raise NotImplementedError
  end

  # Importer::Base reads a path, so the attachment has to reach disk. It reads
  # a .zip holding one CSV itself, and a bare CSV or spreadsheet as well.
  #
  # Nothing about the file's name is passed down: the rows record the run, and
  # the run holds the file. Which is just as well - ActiveStorage writes the
  # attachment to a tempfile called something like
  # ActiveStorage-16851-20260930-8-9wqicn.csv.
  def with_file
    import_run.file.open { |file| yield(file.path) }
  end

  def record_failure(error, message = error.message)
    # A failure outside the importer - a taxonomy that has since been
    # deleted - leaves no logs, so the message is all there is.
    #
    # Written past validation on purpose: recording that it failed matters more
    # than the row being valid, and update! would raise a second error on top
    # of the one being handled.
    # rubocop:disable Rails/SkipsModelValidations
    import_run&.update_columns(
      status: ImportRun::FAILED,
      logs: [ { level: 'error', message: message } ],
      finished_at: Time.current,
      updated_at: Time.current
    )
    # rubocop:enable Rails/SkipsModelValidations
  end
end
