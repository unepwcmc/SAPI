class CaptivityProcess < ActiveRecord::Base
  track_who_does_it
  belongs_to :taxon_concept
  belongs_to :geo_entity
  belongs_to :start_event, :class_name => 'Event'
  belongs_to :m_taxon_concept, :foreign_key => :taxon_concept_id

  validates :taxon_concept, presence: true
  validates :geo_entity, presence: true

  # enum status: [:ongoing, :trade_suspension, :closed]
end
