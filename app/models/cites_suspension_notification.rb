class CitesSuspensionNotification < Event
  attr_accessible :subtype, :new_subtype, :end_date
  attr_accessor :new_subtype
  has_many :started_suspensions, :foreign_key => :start_notification_id, :class_name => 'Suspension'
  has_many :ended_suspensions, :foreign_key => :end_notification_id, :class_name => 'Suspension'

  validates :designation_id, :presence => true
  validate :designation_is_cites
  validates :effective_at, :presence => true

  before_save :handle_new_subtype

  def handle_new_subtype
    unless new_subtype.blank?
      self.subtype = new_subtype
    end
  end

  def self.bases_for_suspension
    select(:subtype).uniq
  end

  def can_be_deleted?
    started_suspensions.count == 0 && ended_suspensions.count == 0
  end

end
