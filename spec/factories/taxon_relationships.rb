FactoryGirl.define do

  factory :taxon_relationship_type do
    sequence(:name) { |n| "INCLUDES#{n}" }
    is_bidirectional false
    is_intertaxonomic true
  end

  factory :taxon_relationship do
    taxon_relationship_type
    taxon_concept
    other_taxon_concept
  end
end
