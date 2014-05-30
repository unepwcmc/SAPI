# == Schema Information
#
# Table name: admin_iucn_mappings
#
#  id               :integer          not null, primary key
#  taxon_concept_id :integer
#  iucn_taxon_id    :integer
#  iucn_taxon_name  :string(255)
#  iucn_author      :string(255)
#  iucn_category    :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  details          :hstore
#  synonym_id       :integer
#

class IucnMapping < ActiveRecord::Base
  attr_accessible :iucn_author, :iucn_category, :iucn_taxon_id,
    :iucn_taxon_name, :taxon_concept_id, :details, :synonym_id

  serialize :details, ActiveRecord::Coders::Hstore
  belongs_to :taxon_concept
  belongs_to :synonym, :class_name => 'TaxonConcept'

  scope :filter, lambda { |option|
    case option
    when "ALL"
      scoped
    when "MATCHING"
      where('iucn_taxon_id IS NOT NULL')
    when "NON_MATCHING"
      where(:iucn_taxon_id => nil)
    else
      where("details->'match' = ?", option)
    end
  }
end
