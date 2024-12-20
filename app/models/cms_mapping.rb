# == Schema Information
#
# Table name: cms_mappings
#
#  id               :integer          not null, primary key
#  taxon_concept_id :integer
#  cms_uuid         :string(255)
#  cms_taxon_name   :string(255)
#  cms_author       :string(255)
#  details          :hstore
#  accepted_name_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class CmsMapping < ApplicationRecord
  # Migrated to controller (Strong Parameters)
  # attr_accessible :accepted_name_id, :cms_author, :cms_taxon_name, :cms_uuid, :details, :taxon_concept_id

  # serialize :details, coder: ActiveRecord::Coders::Hstore
  belongs_to :taxon_concept, optional: true
  belongs_to :accepted_name, class_name: 'TaxonConcept', optional: true

  scope :index_filter, lambda { |option|
    case option
    when 'MATCHES'
      where.not(taxon_concept_id: nil)
    when 'MISSING_SPECIES_PLUS'
      where(taxon_concept_id: nil)
    else
      all
    end
  }
end
