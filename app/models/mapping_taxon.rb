# == Schema Information
#
# Table name: mapping_taxa
#
#  id                    :uuid             not null, primary key
#  accepted_taxon_nid    :string
#  author_year           :string
#  name_status           :string           not null
#  scientific_name       :string           not null
#  source_file           :string           not null
#  taxon_nid             :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  matchable_taxonomy_id :bigint           not null
#  rank_id               :integer
#
# Indexes
#
#  index_mapping_taxa_on_accepted_nid           (matchable_taxonomy_id,taxon_nid) WHERE ((name_status)::text = 'A'::text)
#  index_mapping_taxa_on_concept                (matchable_taxonomy_id,accepted_taxon_nid)
#  index_mapping_taxa_on_matchable_taxonomy_id  (matchable_taxonomy_id)
#  index_mapping_taxa_on_rank_id                (rank_id)
#
# Foreign Keys
#
#  fk_rails_...  (matchable_taxonomy_id => matchable_taxonomies.id)
#  fk_rails_...  (rank_id => ranks.id)
#
# The table name stays plural-of-taxon; Rails cannot inflect it, and adding a
# global taxon/taxa rule would change `"taxon".pluralize` everywhere else.
class MappingTaxon < ApplicationRecord
  self.table_name = 'mapping_taxa'

  ACCEPTED = 'A'.freeze

  belongs_to :matchable_taxonomy
  belongs_to :rank, optional: true

  validates :name_status, presence: true
  validates :scientific_name, presence: true
  validates :source_file, presence: true

  scope :accepted, -> { where(name_status: ACCEPTED) }

  # taxon_nid is only unique among accepted names, so a bare where can match a
  # synonym instead of missing: CITES issues its synonyms their own ids, and
  # looking one up would return that synonym rather than nothing. Reads go
  # through here so the accepted filter cannot be left off - and so a version
  # filter, should versioning ever arrive, lands in one place.
  def self.lookup(matchable_taxonomy:, taxon_nid:)
    accepted.where(matchable_taxonomy: matchable_taxonomy, taxon_nid: taxon_nid)
  end

  # The scope an upload clears before inserting, named for the same reason: one
  # place to change when the unit being replaced changes.
  def self.import_scope(matchable_taxonomy:)
    where(matchable_taxonomy: matchable_taxonomy)
  end

  # What is loaded, per platform, for the admin page's resting state. Returns a
  # hash keyed by matchable_taxonomy_id so the caller can merge it against the
  # full registry and show the platforms that hold nothing.
  def self.summary_by_taxonomy
    group(:matchable_taxonomy_id).pluck(
      Arel.sql('matchable_taxonomy_id'),
      Arel.sql('count(*)'),
      Arel.sql("count(*) FILTER (WHERE name_status = 'A')"),
      Arel.sql('max(source_file)'),
      Arel.sql('max(created_at)')
    ).to_h do |id, names, accepted, source_file, loaded_at|
      [ id, { names: names, accepted: accepted, source_file: source_file, loaded_at: loaded_at } ]
    end
  end

  def accepted?
    name_status == ACCEPTED
  end
end
