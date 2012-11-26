# == Schema Information
#
# Table name: taxon_concept_geo_entities
#
#  id               :integer          not null, primary key
#  taxon_concept_id :integer          not null
#  geo_entity_id    :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class TaxonConceptGeoEntity < ActiveRecord::Base
  attr_accessible :geo_entity_id, :taxon_concept_id
  belongs_to :geo_entity
  belongs_to :taxon_concept
end
