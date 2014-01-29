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

class EuRegulation < Event
  attr_accessible :listing_changes_event_id, :end_date
  attr_accessor :listing_changes_event_id

  has_many :listing_changes, :foreign_key => :event_id,
    :dependent => :destroy

  validate :designation_is_eu
  validates :effective_at, :presence => true


  def can_be_deleted?
    true
  end

end
