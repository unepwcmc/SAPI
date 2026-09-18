# The registry of platforms the intertaxonomic mapping service knows about.
# Seeded, never uploaded, so both mapping tables can reference it safely
# regardless of what order their files arrive in.
#
# The list is open: a new platform is a new row, not a code change.
# == Schema Information
#
# Table name: matchable_taxonomies
#
#  id         :bigint           not null, primary key
#  code       :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_matchable_taxonomies_on_code  (code) UNIQUE
#
class MatchableTaxonomy < ApplicationRecord
  has_many :mapping_taxa,
    class_name: 'MappingTaxon',
    dependent: :restrict_with_error
  has_many :mapping_matches,
    dependent: :restrict_with_error
  has_many :foreign_mapping_matches,
    class_name: 'MappingMatch',
    foreign_key: :foreign_matchable_taxonomy_id,
    inverse_of: :foreign_matchable_taxonomy,
    dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  def to_s
    code
  end
end
