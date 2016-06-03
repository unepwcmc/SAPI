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

class CitesCop < Event
  attr_accessible :is_current
  has_many :listing_changes, :foreign_key => :event_id
  has_many :hash_annotations, :class_name => 'Annotation', :foreign_key => :event_id

  validate :designation_is_cites
  validates :effective_at, :presence => true

  def self.elibrary_document_types
    [Document::Proposal]
  end

  private

  def dependent_objects_map
    {
      'listing changes' => listing_changes
    }
  end

end
