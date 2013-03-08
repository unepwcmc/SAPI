# == Schema Information
#
# Table name: species_listings
#
#  id             :integer          not null, primary key
#  designation_id :integer          not null
#  name           :string(255)      not null
#  abbreviation   :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class SpeciesListing < ActiveRecord::Base
  attr_accessible :designation_id, :name, :abbreviation

  belongs_to :designation
  has_many :listing_changes

  validates :name, :presence => true, :uniqueness => {:scope => :designation_id}
  validates :abbreviation, :presence => true, :uniqueness => {:scope => :designation_id}

  def can_be_deleted?
    listing_changes.count == 0
  end

end
