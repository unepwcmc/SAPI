# == Schema Information
#
# Table name: species_listings
#
#  id             :integer          not null, primary key
#  designation_id :integer
#  name           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  abbreviation   :string(255)
#

class SpeciesListing < ActiveRecord::Base
  attr_accessible :designation_id, :name, :abbreviation

  belongs_to :designation
  has_many :listing_changes

  validates :name, :presence => true, :uniqueness => {:scope => :designation_id}
  validates :abbreviation, :presence => true, :uniqueness => {:scope => :designation_id}

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
