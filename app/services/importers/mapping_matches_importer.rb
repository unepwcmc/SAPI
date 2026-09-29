# match-results-<a>-<b>.csv -> mapping_matches. One file, one taxonomy pair,
# one fixed d1/d2 orientation throughout.
#
# Rows are written name-level and collapsed to one per concept pair afterwards
# by MappingMatch.collapse!, which needs the whole set and so cannot run inside
# a streaming import.
#
# Nothing here checks that the accepted ids resolve to a taxon: the taxa file
# for either side may not have been uploaded yet, and requiring it would put
# the two files in a fixed order. Unresolvable matches are kept, hidden from
# the API by its inner join, and counted by the dangling-reference report.
class Importers::MappingMatchesImporter < Importer::Base
  target_model MappingMatch
  mode :raw_insert_all
  batch_size 5_000

  # The wide export carries 55 columns; these ten are the ones that survive.
  # The other 45 are verbatim copies of both taxonomy files, discarded so there
  # is never a question of which copy is authoritative.
  required_headers(
    {
      'd1_Id_Accepted' => :taxon_nid,
      'd2_Id_Accepted' => :foreign_taxon_nid,
      'd1_Scientific.Name' => :matched_name,
      'd1_Status' => :matched_name_status,
      'd2_Scientific.Name' => :foreign_matched_name,
      'd2_Status' => :foreign_matched_name_status,
      'confidence_level' => :match_confidence,
      'exclude' => :exclude
    }
  )

  derived_attributes %i[matchable_taxonomy_id foreign_matchable_taxonomy_id source_file]

  attr_reader :matchable_taxonomy, :foreign_matchable_taxonomy

  def initialize(file_path:, matchable_taxonomy:, foreign_matchable_taxonomy:)
    super(file_path: file_path)
    @matchable_taxonomy = matchable_taxonomy
    @foreign_matchable_taxonomy = foreign_matchable_taxonomy
  end

  private

  # 95% of the wide export is candidate pairs that did not match - 372,271 of
  # 390,457 rows in the sample. They carry no confidence and no match, and are
  # of no use here.
  #
  # The narrower format the spec describes would emit matched rows only and
  # carry no `matched` column, so its absence means every row counts.
  def exclude_row?(row)
    return false unless row.key?('matched')

    Importer::RowTransformer.considered_blank?(row['matched']) || row['matched'].to_s.strip == 'NA'
  end

  def cast_matchable_taxonomy_id(_raw_value)
    matchable_taxonomy.id
  end

  def cast_foreign_matchable_taxonomy_id(_raw_value)
    foreign_matchable_taxonomy.id
  end

  def cast_source_file(_raw_value)
    File.basename(file_path)
  end

  # R writes NA for an unset boolean, and the column is NOT NULL. Unset means
  # not excluded; it is `NA` on every row of the sample, so the true branch is
  # so far untested against real data.
  def cast_exclude(raw_value)
    value = raw_value.to_s.strip
    return false if value.empty? || value == 'NA'

    ActiveModel::Type::Boolean.new.cast(value) || false
  end
end
