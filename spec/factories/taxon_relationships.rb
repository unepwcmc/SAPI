FactoryGirl.define do

  TaxonRelationshipType.dict.each do |type|
    factory type.downcase.to_sym, class: TaxonRelationship do |f|
      f.taxon_relationship_type { TaxonRelationshipType.find_by_name(type) }
      f.association :taxon_concept
      f.association :other_taxon_concept
    end
  end

end