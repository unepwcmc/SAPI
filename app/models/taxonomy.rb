# == Schema Information
#
# Table name: taxonomies
#
#  id         :integer          not null, primary key
#  name       :string(255)      default("DEAFAULT TAXONOMY"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Taxonomy < ActiveRecord::Base
  include Dictionary
  build_dictionary :cites_eu, :cms

  attr_accessible :name
  has_many :designations
  has_many :taxon_concepts

  validates :name, :presence => true, :uniqueness => true
  validates :name,
    :inclusion => {:in => self.dict, :message => 'cannot change protected name'},
    :if => lambda { |t| t.name_changed? && t.class.dict.include?(t.name_was) },
    :on => :update

  before_destroy :check_destroy_allowed

  private

  def check_destroy_allowed
    unless can_be_deleted?
      errors.add(:base, "not allowed")
      return false
    end
  end

  def can_be_deleted?
    !has_protected_name? && !has_dependent_objects?
  end

  def has_dependent_objects?
    !(designations.count == 0 &&
    taxon_concepts.count == 0)
  end

  def has_protected_name?
    self.class.dict.include? self.name
  end

end
