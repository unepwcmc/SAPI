# == Schema Information
#
# Table name: events
#
#  id                   :integer          not null, primary key
#  description          :text
#  effective_at         :datetime
#  end_date             :datetime
#  extended_description :text
#  is_current           :boolean          default(FALSE), not null
#  multilingual_url     :text
#  name                 :string(255)
#  private_url          :text
#  published_at         :datetime
#  subtype              :string(255)
#  type                 :string(255)      default("Event"), not null
#  url                  :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  created_by_id        :integer
#  designation_id       :integer
#  elib_legacy_id       :integer
#  legacy_id            :integer
#  updated_by_id        :integer
#
# Foreign Keys
#
#  events_created_by_id_fk   (created_by_id => users.id)
#  events_designation_id_fk  (designation_id => designations.id)
#  events_updated_by_id_fk   (updated_by_id => users.id)
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
