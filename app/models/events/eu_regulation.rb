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

class EuRegulation < EuEvent
  include Deletable

  # Migrated to controller (Strong Parameters)
  # attr_accessible :listing_changes_event_id, :end_date
  attr_accessor :listing_changes_event_id

  has_many :listing_changes, :foreign_key => :event_id,
    :dependent => :destroy

  validate :designation_is_eu
  validates :effective_at, :presence => true

  after_commit :async_event_listing_changes_copy_worker, on: :create

  def activate!
    super
    EuRegulationActivationWorker.perform_async(id, true)
  end

  def deactivate!
    super
    EuRegulationActivationWorker.perform_async(id, false)
  end

  private

  def async_event_listing_changes_copy_worker
    unless listing_changes_event_id.blank?
      EventListingChangesCopyWorker.perform_async(
        listing_changes_event_id.to_i, id
      )
    end
  end
end
