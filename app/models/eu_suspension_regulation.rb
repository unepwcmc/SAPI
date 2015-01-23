# == Schema Information
#
# Table name: events
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  designation_id       :integer
#  description          :text
#  url                  :text
#  is_current           :boolean          default(FALSE), not null
#  type                 :string(255)      default("Event"), not null
#  effective_at         :datetime
#  published_at         :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  legacy_id            :integer
#  end_date             :datetime
#  subtype              :string(255)
#  updated_by_id        :integer
#  created_by_id        :integer
#  extended_description :text
#  multilingual_url     :text
#

class EuSuspensionRegulation < Event
  attr_accessible :eu_suspensions_event_id
  attr_accessor :eu_suspensions_event_id

  has_many :eu_suspensions, :foreign_key => :start_event_id,
    :dependent => :destroy

  validate :designation_is_eu
  validates :effective_at, :presence => true
  validate :end_date_presence

  def name_and_date
    "#{self.name} (Effective from: #{self.effective_at.strftime("%d/%m/%Y")})"
  end

  private

  def dependent_objects_map
    {
      'EU suspensions' => eu_suspensions
    }
  end

  def end_date_presence
    unless is_current? ^ end_date.present?
      errors.add(:base, "Is current and End date are mutually exclusive")
    end
  end

end
