# A plain, JSON-safe array of hashes (no custom objects, no exceptions embedded raw),
# added to as row-level problems are found and closed out with a summary entry once
# import! finishes, so a caller (a Job, an ImportRun model) can persist or process it
# without needing to know anything about how the import ran.
#
# Standalone - constructible and usable with no Importer::Base instance at all.
class Importer::Logger
  attr_reader :entries

  def initialize
    @entries = []
  end

  def error(row:, message:, column: nil)
    entries << { level: 'error', row:, column:, message: }.compact
  end

  # Unlike error, never raised alongside - for a problem worth surfacing without making
  # import! itself report failure (see Importer::Base#import!'s reset_pk_sequence! rescue).
  def warning(message:)
    entries << { level: 'warning', message: }
  end

  def summary(processed:, written:, skipped:, excluded:)
    entries << {
      level: 'info',
      message: 'import completed',
      processed:,
      written:,
      skipped:,
      excluded:
    }
  end
end
