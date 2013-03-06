class Event < ActiveRecord::Base
  attr_accessible :name, :designation_id, :description, :url, :effective_at,
    :listing_changes_event_id
  attr_accessor :listing_changes_event_id
  belongs_to :designation
  has_many :listing_changes
  validates :name, :presence => true, :uniqueness => true

  scope :with_effective_date, where('effective_at IS NOT NULL').order('name')

  def effective_at_formatted
    effective_at && effective_at.strftime("%d/%m/%y")
  end

  def can_be_activated?
    current_event = designation && designation.events.
      where(:is_current => true).order('effective_at DESC').first
      puts current_event.inspect
    designation.is_eu? && !is_current && (
      current_event && current_event.effective_at < effective_at ||
      current_event.nil?
    )
  end

  def activate!
    update_attribute(:is_current, true)
    notify_observers(:after_activate)
  end

  def can_be_deleted?
    listing_changes.count == 0
  end

end
