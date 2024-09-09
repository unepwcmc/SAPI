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

class CitesCop < Event
  include Deletable

  # Migrated to controller (Strong Parameters)
  # attr_accessible :is_current

  ##
  # The only time we would delete a CoP/EU regulation is just after we've
  # created it by mistake, but we don't want to be able to delete the CoP
  # event once it's started to be populated, whereas an EU Regulation
  # starts off being populated with lots of associated data so we can't
  # restrict deletion.
  has_many :listing_changes,
    dependent: :restrict_with_error,
    foreign_key: :event_id

  has_many :hash_annotations,
    class_name: 'Annotation',
    dependent: :destroy,
    foreign_key: :event_id

  validate :designation_is_cites
  validates :effective_at, presence: true

  before_validation do
    cites = Designation.find_by(name: 'CITES')
    self.designation_id = cites && cites.id
  end

  def self.elibrary_document_types
    [ Document::Proposal ]
  end

private

  def dependent_objects_map
    {
      'listing changes' => listing_changes
    }
  end
end
