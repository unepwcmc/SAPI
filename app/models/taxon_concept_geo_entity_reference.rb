# == Schema Information
#
# Table name: taxon_concept_geo_entity_references
#
#  id                          :integer          not null, primary key
#  taxon_concept_geo_entity_id :integer
#  reference_id                :integer
#

class TaxonConceptGeoEntityReference < ActiveRecord::Base
  attr_accessible :reference_id, :taxon_concept_geo_entity_id
end
