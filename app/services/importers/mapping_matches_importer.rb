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

  attr_reader :matchable_taxonomy, :foreign_matchable_taxonomy, :source_file

  # source_file is the name the file arrived under, which is not the path it is
  # read from: an upload reaches disk as an ActiveStorage tempfile, and
  # `ActiveStorage-16851-...xlsx` names nothing anyone can re-export.
  def initialize(file_path:, matchable_taxonomy:, foreign_matchable_taxonomy:, source_file: nil)
    super(file_path: file_path)
    @matchable_taxonomy = matchable_taxonomy
    @foreign_matchable_taxonomy = foreign_matchable_taxonomy
    @source_file = source_file || File.basename(file_path)
  end

  private

  # The file now states which taxonomy each side is, but the upload form still
  # asks, because the admin is choosing what gets replaced and a file can be
  # pointed at the wrong pair. Checked rather than trusted either way round:
  # an import clears everything already held for the pair it was told, so being
  # wrong destroys data belonging to a pair nobody touched.
  #
  # Raised rather than skipped - a file describing another pair is not a bad
  # row, it is the wrong file. ImportError aborts the run, and because
  # Mapping::FileImport rescues outside its transaction, the delete that ran
  # before it has already rolled back.
  def before_batch(batch)
    batch.each { |entry| assert_datasets!(entry[:row]) }
  end

  # Exports before October carry no dataset columns, and a blank says nothing,
  # so neither is treated as a disagreement.
  def assert_datasets!(row)
    near = row['d1_dataset'].to_s.strip
    far = row['d2_dataset'].to_s.strip

    return if states?(near, matchable_taxonomy) && states?(far, foreign_matchable_taxonomy)

    # The likeliest mistake by far, and the one worth naming: both taxonomies
    # are right, they were just chosen in the other order.
    if states?(near, foreign_matchable_taxonomy) && states?(far, matchable_taxonomy)
      raise Importer::Base::ImportError,
        "This file has #{near} first and #{far} second, but it was uploaded the " \
        'other way round. Swap the two taxonomies and upload it again.'
    end

    raise Importer::Base::ImportError,
      "This file matches #{near} to #{far}, but it was uploaded as " \
      "#{matchable_taxonomy.code} to #{foreign_matchable_taxonomy.code}."
  end

  def states?(value, taxonomy)
    value.empty? || value == 'NA' || value.casecmp?(taxonomy.code)
  end

  # A wide export is mostly candidate pairs that did not match - 372,271 of
  # 390,457 rows in the September file - and those are of no use here.
  #
  # A row counts if it carries either a match or a confidence, not only a match.
  # `matched` names the rule that fired, so a match a person asserted has none:
  # all three verified rows in the October export say matched = NA. Filtering on
  # that column alone threw away precisely the hand-curated ones.
  #
  # An export carrying neither column has already been filtered, so every row
  # counts.
  def exclude_row?(row)
    %w[matched confidence_level].none? { |header| stated?(row, header) }
  end

  def stated?(row, header)
    return false unless row.key?(header)

    value = row[header]

    !Importer::RowTransformer.considered_blank?(value) && value.to_s.strip != 'NA'
  end

  def cast_matchable_taxonomy_id(_raw_value)
    matchable_taxonomy.id
  end

  def cast_foreign_matchable_taxonomy_id(_raw_value)
    foreign_matchable_taxonomy.id
  end

  def cast_source_file(_raw_value)
    source_file
  end

  # A status is missing exactly when a person asserted the match rather than a
  # rule finding it, and R writes that absence as the string NA. Stored as NULL
  # so match_type can say there is no name-status pair, rather than reporting a
  # match type of NANA.
  def cast_matched_name_status(raw_value)
    status_or_nil(raw_value)
  end

  def cast_foreign_matched_name_status(raw_value)
    status_or_nil(raw_value)
  end

  def status_or_nil(raw_value)
    value = raw_value.to_s.strip

    value.empty? || value == 'NA' ? nil : value
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
