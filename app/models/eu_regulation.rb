# == Schema Information
#
# Table name: events
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  designation_id :integer
#  description    :text
#  url            :text
#  is_current     :boolean          default(FALSE), not null
#  type           :string(255)      default("Event"), not null
#  effective_at   :datetime
#  published_at   :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  legacy_id      :integer
#  end_date       :datetime
#  subtype        :string(255)
#  updated_by_id  :integer
#  created_by_id  :integer
#

class EuRegulation < Event
  attr_accessible :listing_changes_event_id, :end_date
  attr_accessor :listing_changes_event_id

  has_many :listing_changes, :foreign_key => :event_id,
    :dependent => :destroy

  validate :designation_is_eu
  validates :effective_at, :presence => true



  def activate!
    super
    notify_observers(:after_activate)
  end

  def deactivate!
    super
    notify_observers(:after_deactivate)
  end

end
