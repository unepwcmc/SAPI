# Resolves a declared `mode` to its concrete loader class - the single source of truth
# Importer::Base consults both at config-validation time (before any loader is
# constructed, to check capability flags like .supports_on_failure_skip?) and to
# actually build the loader for a run.
module Importer::Loaders
  def self.class_for(mode)
    case mode
    when :raw_insert_all then Importer::Loaders::RawInsertAll
    when :raw_upsert_all then Importer::Loaders::RawUpsertAll
    when :activerecord then Importer::Loaders::PlainRecord
    when :activerecord_import then Importer::Loaders::ActiverecordImport
    else raise NotImplementedError, "#{mode} mode is not implemented yet"
    end
  end
end
