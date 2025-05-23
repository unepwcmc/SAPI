# == Schema Information
#
# Table name: iucn_mappings
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
#  accepted_name_id :integer
#

class IucnMapping < ApplicationRecord
  # Used by IucnMappingManager
  # attr_accessible :iucn_author, :iucn_category, :iucn_taxon_id,
  #   :iucn_taxon_name, :taxon_concept_id, :details, :accepted_name_id

  # serialize :details, coder: ActiveRecord::Coders::Hstore
  belongs_to :taxon_concept
  belongs_to :accepted_name, class_name: 'TaxonConcept', optional: true

  scope :index_filter, lambda { |option|
    case option
    when 'ALL'
      all
    when 'MATCHING'
      where.not(iucn_taxon_id: nil)
    when 'NON_MATCHING'
      where(iucn_taxon_id: nil)
    when 'SYNONYMS'
      where.not(accepted_name_id: nil)
    when 'ACCEPTED'
      where(accepted_name_id: nil)
    else
      where("details->'match' = ?", option)
    end
  }
end
