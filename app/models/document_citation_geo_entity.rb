# == Schema Information
#
# Table name: document_citation_geo_entities
#
#  id                   :integer          not null, primary key
#  document_citation_id :integer
#  geo_entity_id        :integer
#  created_by_id        :integer
#  updated_by_id        :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class DocumentCitationGeoEntity < ActiveRecord::Base
  track_who_does_it
  attr_accessible :created_by_id, :document_citation_id, :geo_entity_id, :updated_by_id
  belongs_to :geo_entity
  belongs_to :document_citation, touch: true
  validates :geo_entity_id, uniqueness: {
    scope: :document_citation_id,
    message: 'geo entity citation already present'
  }

  after_destroy do |dc_ge|
    dc_ge.document_citation.touch
  end
end
