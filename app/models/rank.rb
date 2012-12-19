# == Schema Information
#
# Table name: ranks
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  parent_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Rank < ActiveRecord::Base
  attr_accessible :name, :parent_id
  include Dictionary
  build_dictionary :kingdom, :phylum, :class, :order, :family, :subfamily, :genus, :species, :subspecies

  belongs_to :parent, :class_name => Rank

  validates :name, :presence => true, :uniqueness => true

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
