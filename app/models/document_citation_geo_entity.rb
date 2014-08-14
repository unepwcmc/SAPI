class DocumentCitationGeoEntity < ActiveRecord::Base
  track_who_does_it
  attr_accessible :created_by_id, :document_citation_id, :geo_entity_id, :updated_by_id
  belongs_to :geo_entity
end
