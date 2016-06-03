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
#  elib_legacy_id       :integer
#

class EuSuspensionRegulation < Event
  attr_accessible :eu_suspensions_event_id
  attr_accessor :eu_suspensions_event_id

  has_many :eu_suspensions, :foreign_key => :start_event_id,
    :dependent => :destroy
  has_many :ended_eu_suspensions, class_name: EuSuspension,
    foreign_key: :end_event_id, dependent: :nullify

  validate :designation_is_eu
  validates :effective_at, :presence => true
  validate :end_date_presence

  def name_and_date
    "#{self.name} (Effective from: #{self.effective_at.strftime("%d/%m/%Y")})"
  end

  def touch_suspensions_and_taxa
    eu_suspensions = EuSuspension.where([
      "start_event_id = :to_event_id OR end_event_id = :to_event_id",
      to_event_id: self.id
    ])
    eu_suspensions.update_all(
      updated_at: Time.now, updated_by_id: self.updated_by_id
    )
    TaxonConcept.joins(:eu_suspensions).merge(eu_suspensions).update_all(
      dependents_updated_at: Time.now,
      dependents_updated_by_id: self.updated_by_id
    )
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
