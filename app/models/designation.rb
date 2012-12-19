# == Schema Information
#
# Table name: designations
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Designation < ActiveRecord::Base
  attr_accessible :name
  include Dictionary
  build_dictionary :cites

  validates :name, :presence => true, :uniqueness => true
  has_many :species_listings

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
