# What the two taxon mapping uploads happen to have in common. Not a framework
# for imports in general - another kind of upload may need none of this shape,
# and Import deliberately does not impose one.
#
# Both mapping uploads are a zip holding one CSV, replace everything in their
# scope, and have nothing to do afterwards but record what the importer said.
class Imports::MappingJob < ApplicationJob
  # The kinds of upload this family answers to. The imports table is shared -
  # anything using Importer::Base can write to it - so the Taxon Mapping page
  # has to say which rows are its own rather than showing whatever is newest.
  KINDS = %w[mapping_taxa mapping_matches].freeze

  def perform(import_id)
    @import = Import.find(import_id)
    # A retry of a job whose upload already ran would replace the scope a
    # second time, so only a pending row is picked up.
    return unless import.pending?

    import.update!(status: Import::RUNNING, started_at: Time.current)
    result = with_file { |path, source_file| load(path, source_file) }

    import.update!(
      status: result.success? ? Import::DONE : Import::FAILED,
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

  attr_reader :import

  def load(_path, _source_file)
    raise NotImplementedError
  end

  # Importer::Base reads a path, so the attachment has to reach disk. A bare
  # spreadsheet is accepted as well as a zip, so a file can be re-run without
  # wrapping it first.
  #
  # Which it is has to be decided by extension, not by the first four bytes: an
  # .xlsx is itself a zip, so sniffing the magic number sends one down the
  # unwrap path and reports the ten parts of its OOXML package as ten files
  # someone meant to upload. ActiveStorage keeps the uploaded name's extension
  # on the tempfile, so it survives the round trip. Whether the file inside is
  # one the importer can read is Importer::Base's to say, not this job's.
  # Yields the path to read and the name to record with the rows. They differ:
  # ActiveStorage writes the attachment to a tempfile, so the path is called
  # something like ActiveStorage-16851-20260930-8-9wqicn.xlsx, which names
  # nothing anyone could re-export. For a zip it is the member's own name,
  # which says more about which export it is than the wrapper does.
  def with_file(&)
    import.file.open do |file|
      if zip?(file.path)
        extract(file.path, &)
      else
        yield(file.path, import.filename)
      end
    end
  end

  def zip?(path)
    File.extname(path).casecmp?('.zip')
  end

  def extract(zip_path)
    Zip::File.open(zip_path) do |zip|
      entry = zip.get_entry(sole_entry_name(zip))

      Dir.mktmpdir do |dir|
        path = File.join(dir, File.basename(entry.name))
        # Copied rather than Entry#extract: that takes a path relative to a
        # destination directory, so an absolute one comes out joined to the
        # working directory. Streaming also keeps a 200 MB member off the heap.
        entry.get_input_stream { |io| File.open(path, 'wb') { |out| IO.copy_stream(io, out) } }
        yield path, File.basename(entry.name)
      end
    end
  end

  def sole_entry_name(zip)
    # Directory entries, and the __MACOSX sidecars a zip made on a Mac carries,
    # are not files anyone meant to upload.
    names =
      zip.entries.reject(&:directory?).map(&:name).reject do |name|
        name.start_with?('__MACOSX/') || File.basename(name).start_with?('.')
      end

    raise ArgumentError, "expected one file in the zip, found #{names.size}" unless names.one?

    names.first
  end

  def record_failure(error, message = error.message)
    # A failure outside the importer - an unreadable zip, a taxonomy that has
    # since been deleted - leaves no logs, so the message is all there is.
    #
    # Written past validation on purpose: recording that it failed matters more
    # than the row being valid, and update! would raise a second error on top
    # of the one being handled.
    # rubocop:disable Rails/SkipsModelValidations
    import&.update_columns(
      status: Import::FAILED,
      logs: [ { level: 'error', message: message } ],
      finished_at: Time.current,
      updated_at: Time.current
    )
    # rubocop:enable Rails/SkipsModelValidations
  end
end
