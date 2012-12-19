# == Schema Information
#
# Table name: change_types
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  designation_id :integer          not null
#

class ChangeType < ActiveRecord::Base
  attr_accessible :designation_id, :name
  include Dictionary
  belongs_to :designation

  validates :name, :presence => true, :uniqueness => {:scope => :designation_id}

  build_dictionary :addition, :deletion, :reservation, :reservation_withdrawal, :exception

  before_destroy :check_destroy_allowed

  private

  def check_destroy_allowed
    unless can_be_deleted?
      errors.add(:base, "not allowed")
      return false
    end
  end

  def can_be_deleted?
    false
  end
end
