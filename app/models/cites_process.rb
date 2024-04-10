class CitesProcess < ApplicationRecord
  include TrackWhoDoesIt
  # Migrated to controller (Strong Parameters)
  # attr_accessible :start_event_id, :geo_entity_id, :resolution, :start_date,
  #                 :taxon_concept_id, :notes, :status, :document, :document_title,
  #                 :created_by_id, :updated_by_id

  belongs_to :taxon_concept
  belongs_to :geo_entity
  belongs_to :start_event, :class_name => 'Event', optional: true
  belongs_to :m_taxon_concept, :foreign_key => :taxon_concept_id, optional: true

  validates :resolution, presence: true
  validates :start_date, presence: true

  validate :start_event_value, if: :is_start_event_present?
  before_validation :set_resolution_value

  def is_current?
    !['Closed'].include? status
  end

  def year
    start_date ? start_date.strftime('%Y') : ''
  end

  def start_date_formatted
    start_date ? start_date.strftime('%d/%m/%Y') : ''
  end

  private

  def start_event_value
    unless  ['CitesAc','CitesPc'].include? self.start_event.type
      errors.add(:start_event, "is not valid")
    end
  end

  def is_start_event_present?
    start_event.present?
  end
end
