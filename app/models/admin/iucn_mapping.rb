class Admin::IucnMapping < ActiveRecord::Base
  attr_accessible :iucn_author, :iucn_category, :iucn_taxon_id,
    :iucn_taxon_name, :taxon_concept_id

  belongs_to :taxon_concept

  scope :filter, lambda { |option|
    case option
      when "ALL"
        scoped
      when "MATCHING"
        where('iucn_taxon_id IS NOT NULL')
      when "NON_MATCHING"
        where(:iucn_taxon_id => nil)
    end
  }
end
