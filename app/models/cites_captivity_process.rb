class CitesCaptivityProcess < ActiveRecord::Base
  track_who_does_it
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

  private
  
  def start_event_value
    event = Event.where("id = ? and type IN (?)", start_event_id, ['CitesAc','CitesPc'])
    if event.blank?
      errors.add(:start_event, "is Invalid")
    end
  end
end
