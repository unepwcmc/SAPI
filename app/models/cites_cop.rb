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

class CitesCop < Event
  attr_accessible :is_current
  has_many :listing_changes, :foreign_key => :event_id
  has_many :hash_annotations, :class_name => 'Annotation', :foreign_key => :event_id

  validate :designation_is_cites
  validates :effective_at, :presence => true

  def can_be_deleted?
    listing_changes.count == 0
  end

end
