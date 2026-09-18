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
end
