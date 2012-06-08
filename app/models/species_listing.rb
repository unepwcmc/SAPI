# == Schema Information
#
# Table name: species_listings
#
#  id             :integer         not null, primary key
#  designation_id :integer
#  name           :string(255)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

class SpeciesListing < ActiveRecord::Base
  attr_accessible :designation_id, :name, :abbreviation

  belongs_to :designation
  has_many :listing_changes
end
