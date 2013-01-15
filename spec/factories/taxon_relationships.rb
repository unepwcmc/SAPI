FactoryGirl.define do

  factory :taxon_relationship_type do
    sequence(:name) {|n| "INCLUDES#{n}" }
    is_bidirectional true
    is_interdesignational true
  end

  factory :taxon_relationship do
    taxon_relationship_type 
    taxon_concept
    other_taxon_concept
  end

  TaxonRelationshipType.dict.each do |type|
    factory type.downcase.to_sym, parent: :taxon_relationship, class: TaxonRelationship do
      taxon_relationship_type { TaxonRelationshipType.find_by_name(type) }
    end
  end

end
