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
# Indexes
#
#  idx_events_where_is_current_on_type_subtype_designation  (type,subtype,designation_id) WHERE is_current
#  index_events_on_created_by_id                            (created_by_id)
#  index_events_on_designation_id                           (designation_id)
#  index_events_on_name                                     (name) UNIQUE
#  index_events_on_type_and_subtype_and_designation_id      (type,subtype,designation_id)
#  index_events_on_updated_by_id                            (updated_by_id)
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

  ##
  # The only time we would delete a CoP/EU regulation is just after we've
  # created it by mistake, but we don't want to be able to delete the CoP
  # event once it's started to be populated, whereas an EU Regulation
  # starts off being populated with lots of associated data so we can't
  # restrict deletion.
  has_many :listing_changes,
    dependent: :destroy,
    foreign_key: :event_id

  has_many :annotations,
    dependent: :destroy,
    foreign_key: :event_id

  validate :designation_is_eu
  validates :effective_at, presence: true

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
    if listing_changes_event_id.present?
      EventListingChangesCopyWorker.perform_async(
        listing_changes_event_id.to_i, id
      )
    end
  end
end
