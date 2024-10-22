# == Schema Information
#
# Table name: document_citation_geo_entities
#
#  id                   :integer          not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  created_by_id        :integer
#  document_citation_id :integer
#  geo_entity_id        :integer
#  updated_by_id        :integer
#
# Indexes
#
#  index_citation_geo_entities_on_geo_entity_id_citation_id  (geo_entity_id,document_citation_id) UNIQUE
#
# Foreign Keys
#
#  document_citation_geo_entities_created_by_id_fk         (created_by_id => users.id)
#  document_citation_geo_entities_document_citation_id_fk  (document_citation_id => document_citations.id)
#  document_citation_geo_entities_geo_entity_id_fk         (geo_entity_id => geo_entities.id)
#  document_citation_geo_entities_updated_by_id_fk         (updated_by_id => users.id)
#

class DocumentCitationGeoEntity < ApplicationRecord
  include TrackWhoDoesIt
  # Used by app/models/nomenclature_change/reassignment_copy_processor.rb and lib/tasks/elibrary/identification_docs_distributions_importer.rb
  # attr_accessible :created_by_id, :document_citation_id, :geo_entity_id, :updated_by_id

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
