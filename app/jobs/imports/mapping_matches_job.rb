# match-results-<a>-<b>.csv - one taxonomy pair.
#
# The far side comes from params because a polymorphic reference holds one
# record and a match file is about two.
class Imports::MappingMatchesJob < Imports::MappingJob
  private

  def load(path)
    Mapping::FileImport.matches(
      file_path: path,
      matchable_taxonomy: import.importable,
      foreign_matchable_taxonomy: MatchableTaxonomy.find(import.params['foreign_matchable_taxonomy_id'])
    )
  end
end
