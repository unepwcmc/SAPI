class EuRegulation < Event
  attr_accessible :listing_changes_event_id
  attr_accessor :listing_changes_event_id
  validates :designation_id, :presence => true
  validate :designation_is_eu
  validates :effective_at, :presence => true

  def can_be_activated?
    current_event = EuRegulation.where(:is_current => true).
      order('effective_at DESC').first
    !is_current && (
      current_event && current_event.effective_at < effective_at ||
      current_event.nil?
    )
  end

  def activate!
    update_attribute(:is_current, true)
    notify_observers(:after_activate)
  end

  protected
    def designation_is_eu
      eu = Designation.find_by_name('EU')
      unless designation_id && eu && designation_id == eu.id
        errors.add(:designation_id, 'should be EU')
      end
    end

end