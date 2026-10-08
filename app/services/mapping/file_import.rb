# One entry point for loading either file family the R pipeline produces.
#
# Both kinds follow the same shape - clear the scope this file owns, insert
# what the file holds, and do it in one transaction so the API never reads a
# half-loaded platform or pair. Matches have a third step, collapsing to one
# row per concept pair, which needs the whole set and so cannot happen inside
# the streaming import.
#
#   Mapping::FileImport.taxa(file_path:, matchable_taxonomy: cites)
#   Mapping::FileImport.matches(file_path:, matchable_taxonomy: cites,
#                           foreign_matchable_taxonomy: iucn)
#
# Which platform a file belongs to is the caller's to say. A taxa file is named
# after its platform but nothing inside it declares one, and a match file does
# not even say which of its two platforms is d1 - the admin picks both from
# dropdowns.
#
# Takes a path to a CSV or spreadsheet and the run that is loading it.
# Unwrapping an upload - zip, ActiveStorage, tempfile - belongs to whatever is
# doing the uploading; the run is what every row is stamped with, so a whole
# upload can be found or removed later.
class Mapping::FileImport
  Result =
    Struct.new(:success, :written, :retained, :logs, keyword_init: true) do
      def success? = success
       def failure? = !success
    end

  def self.taxa(file_path:, matchable_taxonomy:, import_run:)
    new(
      importer: Importers::MappingTaxaImporter.new(
        file_path: file_path, matchable_taxonomy: matchable_taxonomy, import_run: import_run
      ),
      scope: MappingTaxon.import_scope(matchable_taxonomy: matchable_taxonomy)
    ).call
  end

  def self.matches(file_path:, matchable_taxonomy:, foreign_matchable_taxonomy:, import_run:)
    new(
      importer: Importers::MappingMatchesImporter.new(
        file_path: file_path,
        matchable_taxonomy: matchable_taxonomy,
        foreign_matchable_taxonomy: foreign_matchable_taxonomy,
        import_run: import_run
      ),
      scope: MappingMatch.import_scope(
        matchable_taxonomy: matchable_taxonomy,
        foreign_matchable_taxonomy: foreign_matchable_taxonomy
      ),
      collapse: true
    ).call
  end

  def initialize(importer:, scope:, collapse: false)
    @importer = importer
    @scope = scope
    @collapse = collapse
  end

  def call
    retained = nil

    ActiveRecord::Base.transaction do
      scope.delete_all
      importer.import!
      MappingMatch.collapse!(scope) if collapse
      retained = scope.count
    end

    Result.new(
      success: true,
      written: importer.logs.last[:written].to_i,
      retained: retained,
      # Appended to the importer's own summary rather than kept in a column:
      # what survived is not what was written whenever matches are collapsed,
      # and the logs are already where an import says what it did.
      logs: importer.logs + [ { level: 'info', message: 'rows retained', retained: retained } ]
    )
  rescue Importer::Base::ImportError => e
    # Rescued outside the transaction block, so the rollback has already
    # happened by the time this runs. Row-level detail is in the logs; letting
    # the exception through would lose it.
    #
    # The message is appended because the checks that reject a file outright -
    # a missing header, a bad encoding - run before the importer has logged
    # anything, and a failure the admin page cannot explain is no use.
    Result.new(
      success: false, written: 0, retained: 0,
      logs: importer.logs + [ { level: 'error', message: e.message } ]
    )
  end

  private

  attr_reader :importer, :scope, :collapse
end
