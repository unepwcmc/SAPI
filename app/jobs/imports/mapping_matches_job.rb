# match-results-<a>-<b>.csv - one taxonomy pair.
#
# The far side comes from params because a polymorphic reference holds one
# record and a match file is about two.
class Imports::MappingMatchesJob < Imports::MappingJob
  private

  def load(path)
    Mapping::FileImport.matches(
      file_path: path,
      matchable_taxonomy: import_run.importable,
      foreign_matchable_taxonomy:
        MatchableTaxonomy.find(import_run.params['foreign_matchable_taxonomy_id']),
      import_run: import_run
    )
  end
end
