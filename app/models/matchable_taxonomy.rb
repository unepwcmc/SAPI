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
  include Deletable

  # dependent: nil is deliberate, not an omission. Deleting a platform that
  # still holds rows is refused by Deletable's before_destroy, which names
  # every blocker at once and is what Admin::SimpleCrudController reads to
  # report the failure; a database foreign key backs that up. Adding
  # :restrict_with_error here as well would only mean whichever callback runs
  # first decides the wording. Rubocop requires the option to be explicit.
  has_many :mapping_taxa, class_name: 'MappingTaxon', dependent: nil
  has_many :mapping_matches, dependent: nil
  has_many :foreign_mapping_matches,
    class_name: 'MappingMatch',
    foreign_key: :foreign_matchable_taxonomy_id,
    inverse_of: :foreign_matchable_taxonomy,
    dependent: nil

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  def to_s
    code
  end

private

  # Deleting a platform that still holds names or matches would orphan them,
  # and they can only come back by re-uploading the file they came from.
  def dependent_objects_map
    {
      'taxon names' => mapping_taxa,
      'matches' => mapping_matches,
      'matches from the other side' => foreign_mapping_matches
    }
  end
end
