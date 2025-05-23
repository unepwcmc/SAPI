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

class CitesSuspensionNotification < Event
  include Deletable
  # Migrated to controller (Strong Parameters)
  # attr_accessible :subtype, :new_subtype, :end_date
  attr_accessor :new_subtype
  has_many :started_suspensions, foreign_key: :start_notification_id, class_name: 'CitesSuspension'
  has_many :ended_suspensions, foreign_key: :end_notification_id, class_name: 'CitesSuspension'
  has_many :cites_suspension_confirmations, dependent: :destroy
  has_many :confirmed_suspensions, through: :cites_suspension_confirmations

  validate :designation_is_cites
  validates :effective_at, presence: true

  before_save :handle_new_subtype
  before_validation do
    cites = Designation.find_by(name: 'CITES')
    self.designation_id = cites && cites.id
  end

  def handle_new_subtype
    if new_subtype.present?
      self.subtype = new_subtype
    end
  end

  def self.bases_for_suspension
    select(:subtype).distinct
  end

private

  def dependent_objects_map
    {
      'started CITES suspensions' => started_suspensions,
      'ended CITES suspensions' => ended_suspensions
    }
  end
end
