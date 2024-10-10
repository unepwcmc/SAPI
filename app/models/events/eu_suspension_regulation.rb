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

class EuSuspensionRegulation < EuEvent
  include Deletable

  # Migrated to controller (Strong Parameters)
  # attr_accessible :eu_suspensions_event_id
  attr_accessor :eu_suspensions_event_id

  # Because EuSuspensionRegulation events are created with many suspensions
  # copied over from the previous event, it's legitimate to allow cascade
  # deletion via dependent: :destroy.
  #
  # Note that this behaviour differs from the relationship between CITES CoPs
  # and CITES Listings, as the listings are added one by one.
  has_many :eu_suspensions,
    foreign_key: :start_event_id,
    dependent: :destroy

  # These are suspensions which belong to another eu reg but which this eu reg
  # supersedes, therefore we use dependent: nullify
  has_many :ended_eu_suspensions,
    class_name: 'EuSuspension',
    foreign_key: :end_event_id,
    dependent: :nullify

  validate :designation_is_eu
  validates :effective_at, presence: true
  validate :end_date_presence

  after_update :touch_suspensions_and_taxa
  after_commit :after_create_async_tasks, on: :create
  after_commit :async_downloads_cache_cleanup, on: :update

  def name_and_date
    "#{self.name} (Effective from: #{self.effective_at.strftime("%d/%m/%Y")})"
  end

  def touch_suspensions_and_taxa
    eu_suspensions = EuSuspension.where(
      [
        'start_event_id = :to_event_id OR end_event_id = :to_event_id',
        to_event_id: self.id
      ]
    )
    eu_suspensions.update_all(
      updated_at: Time.now, updated_by_id: self.updated_by_id
    )
    TaxonConcept.joins(:eu_suspensions).merge(eu_suspensions).update_all(
      dependents_updated_at: Time.now,
      dependents_updated_by_id: self.updated_by_id
    )
  end

private

  # dependent: destroy is set above, therefore if eu_suspensions exist,
  # we should not prevent deletion.
  # def dependent_objects_map
  #   {
  #     'EU suspensions' => eu_suspensions
  #   }
  # end

  def end_date_presence
    unless is_current? ^ end_date.present?
      errors.add(:base, 'Is current and End date are mutually exclusive')
    end
  end

  def after_create_async_tasks
    if eu_suspensions_event_id.present?
      EventEuSuspensionCopyWorker.perform_async(eu_suspensions_event_id, id)
      DownloadsCacheCleanupWorker.perform_async('eu_decisions')
    end
  end

  def async_downloads_cache_cleanup
    DownloadsCacheCleanupWorker.perform_async('eu_decisions')
  end
end
