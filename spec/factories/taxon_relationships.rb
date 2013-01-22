FactoryGirl.define do

  factory :taxon_relationship_type do
    sequence(:name) {|n| "INCLUDES#{n}" }
    is_bidirectional false
    is_interdesignational true
  end

  factory :taxon_relationship do
    taxon_relationship_type
    taxon_concept
    other_taxon_concept

    TaxonRelationshipType.dict.each do |type_name|
      factory :"#{type_name.downcase}" do
        taxon_relationship_type { TaxonRelationshipType.find_by_name(type_name) }
      end
    end
  end
end
