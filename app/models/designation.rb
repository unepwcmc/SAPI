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

  has_many :species_listings
  has_and_belongs_to_many :references, :join_table => :designation_references
end
