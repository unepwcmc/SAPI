class CitesCaptivityProcess < ActiveRecord::Base
  track_who_does_it
  attr_accessible :start_event_id, :geo_entity_id, :resolution, :start_date, :taxon_concept_id, :notes, :status, :created_by_id, :updated_by_id
  belongs_to :taxon_concept
  belongs_to :geo_entity
  belongs_to :start_event, :class_name => 'Event'
  belongs_to :m_taxon_concept, :foreign_key => :taxon_concept_id

  validates :taxon_concept, presence: true
  validates :geo_entity, presence: true
  validates :resolution, presence: true
  validates :start_date, presence: true

  STATUS = ['Ongoing', 'Trade Suspension', 'Closed']
  RESOLUTION = ['Res. Conf. 17.7 (Rev. CoP18)']
  
  # Change status field to Enum type after upgrading to rails 4.1
  validates :status, presence: true, inclusion: {in: STATUS}
  validate :start_event_value

  def is_current?
    status == 'Ongoing'
  end

  def year
    start_date ? start_date.strftime('%Y') : ''
  end

  def start_date_formatted
    start_date ? start_date.strftime("%d/%m/%Y") : ""
  end

  private
  
  def start_event_value
    unless  ['CitesAc','CitesPc'].include? self.start_event.type
      errors.add(:start_event, "is not valid")
    end
  end
end
