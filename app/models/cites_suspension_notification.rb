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

class CitesSuspensionNotification < Event
  attr_accessible :subtype, :new_subtype, :end_date
  attr_accessor :new_subtype
  has_many :started_suspensions, :foreign_key => :start_notification_id, :class_name => 'CitesSuspension'
  has_many :ended_suspensions, :foreign_key => :end_notification_id, :class_name => 'CitesSuspension'
  has_many :cites_suspension_confirmations, :dependent => :destroy
  has_many :confirmed_suspensions, :through => :cites_suspension_confirmations

  validate :designation_is_cites
  validates :effective_at, :presence => true

  before_save :handle_new_subtype

  def handle_new_subtype
    unless new_subtype.blank?
      self.subtype = new_subtype
    end
  end

  def self.bases_for_suspension
    select(:subtype).uniq
  end

  def can_be_deleted?
    started_suspensions.count == 0 && ended_suspensions.count == 0
  end
end
