# == Schema Information
#
# Table name: mapping_matches
#
#  id                            :uuid             not null, primary key
#  exclude                       :boolean          default(FALSE), not null
#  foreign_matched_name          :string           not null
#  foreign_matched_name_status   :string           not null
#  foreign_taxon_nid             :string           not null
#  match_confidence              :string           not null
#  matched_name                  :string           not null
#  matched_name_status           :string           not null
#  source_file                   :string           not null
#  taxon_nid                     :string           not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  foreign_matchable_taxonomy_id :bigint           not null
#  matchable_taxonomy_id         :bigint           not null
#
# Indexes
#
#  index_mapping_matches_on_foreign_side  (foreign_matchable_taxonomy_id,foreign_taxon_nid)
#  index_mapping_matches_on_near_side     (matchable_taxonomy_id,taxon_nid)
#
# Foreign Keys
#
#  fk_rails_...  (foreign_matchable_taxonomy_id => matchable_taxonomies.id)
#  fk_rails_...  (matchable_taxonomy_id => matchable_taxonomies.id)
#
# There is one source file per unordered pair and no reverse file, so a row is
# stored in whatever orientation its file used and flipped on read. Both the
# direction flip and the match type live here rather than in any caller.
class MappingMatch < ApplicationRecord
  belongs_to :matchable_taxonomy
  belongs_to :foreign_matchable_taxonomy,
    class_name: 'MatchableTaxonomy',
    inverse_of: :foreign_mapping_matches

  validates :taxon_nid, presence: true
  validates :foreign_taxon_nid, presence: true
  validates :matched_name, presence: true
  validates :matched_name_status, presence: true
  validates :foreign_matched_name, presence: true
  validates :foreign_matched_name_status, presence: true
  validates :match_confidence, presence: true
  validates :source_file, presence: true

  scope :included, -> { where(exclude: false) }

  # Which row survives when one concept pair matched through several name pairs.
  # match_type is ranked before confidence, and has to be: the AA pass matches
  # on name without author, so a direct accepted-to-accepted match scores only
  # `high` while its synonym-bridged siblings reach `really high`. Ordering on
  # confidence alone would report a bridged match for a pair that has a direct
  # one. SA and AS rank equally - which side demoted the name to a synonym does
  # not make the match stronger or weaker.
  MATCH_TYPE_PRECEDENCE = { 'AA' => 0, 'SA' => 1, 'AS' => 1, 'SS' => 2 }.freeze

  # Strongest first. The values are R's, carried through unconverted; the API
  # maps them to numbers at the boundary.
  CONFIDENCE_PRECEDENCE = [
    'verified', 'really high', 'high', 'medium-high', 'medium', 'medium-low', 'low'
  ].freeze

  # AA, SA, AS or SS - the two name statuses read together, in this row's own
  # orientation. Flipped rows report the mirrored pair.
  def match_type
    "#{matched_name_status}#{foreign_matched_name_status}"
  end

  # The scope an upload clears before inserting. A pair has to be matched in
  # either orientation, because which platform the source file called d1 is
  # arbitrary and may differ between exports.
  def self.import_scope(matchable_taxonomy:, foreign_matchable_taxonomy:)
    where(
      matchable_taxonomy: matchable_taxonomy,
      foreign_matchable_taxonomy: foreign_matchable_taxonomy
    ).or(
      where(
        matchable_taxonomy: foreign_matchable_taxonomy,
        foreign_matchable_taxonomy: matchable_taxonomy
      )
    )
  end

  # What is loaded, per taxonomy pair. Keyed by the pair's two ids sorted, so a
  # file that named the platforms the other way round still lands on the same
  # entry - which orientation a source file used is arbitrary.
  def self.summary_by_pair
    group(:matchable_taxonomy_id, :foreign_matchable_taxonomy_id).pluck(
      Arel.sql('matchable_taxonomy_id'),
      Arel.sql('foreign_matchable_taxonomy_id'),
      Arel.sql('count(*)'),
      Arel.sql('max(source_file)'),
      Arel.sql('max(created_at)')
    ).each_with_object({}) do |(near, far, matches, source_file, loaded_at), summary|
      # The two orientations are separate groups in SQL but one pair here, so
      # they are folded together rather than one overwriting the other.
      entry = summary[[ near, far ].sort] ||= { matches: 0, source_file: nil, loaded_at: nil }
      entry[:matches] += matches
      entry[:source_file] = [ entry[:source_file], source_file ].compact.max
      entry[:loaded_at] = [ entry[:loaded_at], loaded_at ].compact.max
    end
  end

  # Matches naming a taxon this system does not hold, counted per platform and
  # source file. The API omits these silently - its join onto mapping_taxa is an
  # inner one - so this report is the only place they surface.
  #
  # Both sides are checked: a match dangles if either end is missing.
  def self.unresolved_by_source
    %i[near foreign].flat_map { |side| unresolved_for(side) }
  end

  def self.unresolved_for(side)
    taxonomy_column = side == :near ? 'matchable_taxonomy_id' : 'foreign_matchable_taxonomy_id'
    nid_column = side == :near ? 'taxon_nid' : 'foreign_taxon_nid'

    where(
      "NOT EXISTS (
         SELECT 1 FROM mapping_taxa t
         WHERE t.matchable_taxonomy_id = mapping_matches.#{taxonomy_column}
           AND t.taxon_nid = mapping_matches.#{nid_column}
           AND t.name_status = :accepted
       )",
      accepted: MappingTaxon::ACCEPTED
    ).group(taxonomy_column, :source_file).pluck(
      Arel.sql(taxonomy_column), Arel.sql('source_file'), Arel.sql('count(*)')
    ).map do |taxonomy_id, source_file, count|
      { matchable_taxonomy_id: taxonomy_id, source_file: source_file, unresolved: count }
    end
  end
  private_class_method :unresolved_for

  # Reduces a freshly imported pair to one row per concept pair. The import
  # writes the file's name-level rows as they come - in the sample 18,186 of
  # them, describing 12,552 concept pairs, because one pair can match through
  # every synonym the two platforms share. Collapsing needs the whole set, so
  # it cannot happen inside a streaming import.
  #
  # Deletes rather than rewrites, so the surviving row keeps the names it was
  # actually matched on.
  def self.collapse!(scope)
    ranked = scope.select(:id).to_sql
    connection.execute(<<~SQL.squish)
      DELETE FROM mapping_matches AS m
      USING (
        SELECT id,
               row_number() OVER (
                 PARTITION BY matchable_taxonomy_id, taxon_nid,
                              foreign_matchable_taxonomy_id, foreign_taxon_nid
                 ORDER BY #{match_type_ordering}, #{confidence_ordering}, id
               ) AS rn
        FROM mapping_matches
        WHERE id IN (#{ranked})
      ) AS ranked
      WHERE m.id = ranked.id AND ranked.rn > 1
    SQL
  end

  def self.match_type_ordering
    whens =
      MATCH_TYPE_PRECEDENCE.map do |pair, rank|
        "WHEN #{connection.quote(pair)} THEN #{rank}"
      end
    "CASE matched_name_status || foreign_matched_name_status #{whens.join(' ')} " \
      "ELSE #{MATCH_TYPE_PRECEDENCE.values.max + 1} END"
  end
  private_class_method :match_type_ordering

  def self.confidence_ordering
    whens =
      CONFIDENCE_PRECEDENCE.each_with_index.map do |level, rank|
        "WHEN #{connection.quote(level)} THEN #{rank}"
      end
    "CASE match_confidence #{whens.join(' ')} ELSE #{CONFIDENCE_PRECEDENCE.size} END"
  end
  private_class_method :confidence_ordering
end
