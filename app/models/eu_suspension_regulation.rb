# == Schema Information
#
# Table name: events
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  designation_id :integer
#  effective_at   :datetime
#  published_at   :datetime
#  description    :text
#  url            :text
#  is_current     :boolean          default(FALSE), not null
#  type           :string(255)      default("Event"), not null
#  legacy_id      :integer
#  end_date       :datetime
#  subtype        :string(255)
#

class EuSuspensionRegulation < Event
  attr_accessible :eu_suspensions_event_id
  attr_accessor :eu_suspensions_event_id

  has_many :eu_suspensions, :foreign_key => :start_event_id,
    :dependent => :destroy

  validate :designation_is_eu
  validates :effective_at, :presence => true

  def can_be_deleted?
    eu_suspensions.count == 0
  end

  def name_and_date
    "#{self.name} (Effective from: #{self.effective_at.strftime("%d/%m/%Y")})"
  end
end
