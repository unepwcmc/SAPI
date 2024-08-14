# == Schema Information
#
# Table name: distribution_references
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  created_by_id   :integer
#  distribution_id :integer          not null
#  reference_id    :integer          not null
#  updated_by_id   :integer
#
# Indexes
#
#  index_distribution_references_on_distribution_id         (distribution_id)
#  index_distribution_references_on_reference_id            (reference_id)
#  index_distribution_refs_on_distribution_id_reference_id  (distribution_id,reference_id) UNIQUE
#
# Foreign Keys
#
#  distribution_references_created_by_id_fk                         (created_by_id => users.id)
#  distribution_references_updated_by_id_fk                         (updated_by_id => users.id)
#  taxon_concept_geo_entity_references_reference_id_fk              (reference_id => references.id)
#  taxon_concept_geo_entity_references_taxon_concept_geo_entity_fk  (distribution_id => distributions.id)
#

class DistributionReference < ApplicationRecord
  include TrackWhoDoesIt
  # Used by app/models/cms_mapping_manager.rb
  # attr_accessible :reference_id, :distribution_id, :created_by_id,
  #   :updated_by_id

  belongs_to :reference
  belongs_to :distribution, touch: true

  validates :distribution_id, uniqueness: { scope: :reference_id }
end
