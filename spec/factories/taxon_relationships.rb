# == Schema Information
#
# Table name: taxon_relationships
#
#  id                         :integer          not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  created_by_id              :integer
#  other_taxon_concept_id     :integer          not null
#  taxon_concept_id           :integer          not null
#  taxon_relationship_type_id :integer          not null
#  updated_by_id              :integer
#
# Indexes
#
#  idx_on_other_taxon_concept_id_taxon_concept_id_taxo_2c9706896e  (other_taxon_concept_id,taxon_concept_id,taxon_relationship_type_id) UNIQUE
#  idx_on_taxon_concept_id_other_taxon_concept_id_taxo_71c4a75896  (taxon_concept_id,other_taxon_concept_id,taxon_relationship_type_id) UNIQUE
#  index_taxon_relationships_on_created_by_id                      (created_by_id)
#  index_taxon_relationships_on_taxon_concept_id                   (taxon_concept_id)
#  index_taxon_relationships_on_taxon_relationship_type_id         (taxon_relationship_type_id)
#  index_taxon_relationships_on_updated_by_id                      (updated_by_id)
#
# Foreign Keys
#
#  taxon_relationships_created_by_id_fk               (created_by_id => users.id)
#  taxon_relationships_taxon_concept_id_fk            (taxon_concept_id => taxon_concepts.id)
#  taxon_relationships_taxon_relationship_type_id_fk  (taxon_relationship_type_id => taxon_relationship_types.id)
#  taxon_relationships_updated_by_id_fk               (updated_by_id => users.id)
#
FactoryBot.define do
  factory :taxon_relationship_type do
    sequence(:name) { |n| "INCLUDES#{n}" }
    is_bidirectional { false }
    is_intertaxonomic { true }
  end

  factory :taxon_relationship do
    taxon_relationship_type
    taxon_concept
    other_taxon_concept
  end
end
