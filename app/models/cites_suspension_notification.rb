class CitesSuspensionNotification < Event
  attr_accessible :subtype, :existing_subtype, :new_subtype, :end_date
  has_many :started_suspensions, :foreign_key => :start_notification_id, :class_name => 'Suspension'
  has_many :ended_suspensions, :foreign_key => :end_notification_id, :class_name => 'Suspension'

  validates :designation_id, :presence => true
  validate :designation_is_cites
  validates :effective_at, :presence => true
  validates :end_date, :presence => true

  def self.bases_for_suspension
    select(:subtype).uniq
  end

  def can_be_deleted?
    started_suspensions.count == 0 && ended_suspensions.count == 0
  end

end
