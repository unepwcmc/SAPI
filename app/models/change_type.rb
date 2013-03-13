# == Schema Information
#
# Table name: change_types
#
#  id             :integer          not null, primary key
#  name           :string(255)      not null
#  designation_id :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class ChangeType < ActiveRecord::Base
  attr_accessible :designation_id, :name
  include Dictionary
  belongs_to :designation
  has_many :listing_changes

  validates :name, :presence => true, :uniqueness => {:scope => :designation_id}

  build_dictionary :addition, :deletion, :reservation, :reservation_withdrawal, :exception

  def abbreviation
    self.name.split('_').
      map{|a| a[0..2]}.join('-')
  end

  def print_name
    self.name.titleize
  end

  def can_be_deleted?
    listing_changes.count == 0
  end
end
