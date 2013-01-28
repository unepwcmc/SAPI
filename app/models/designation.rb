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
  attr_accessible :name, :taxonomy_id
  include Dictionary
  build_dictionary :cites, :eu

  validates :name, :presence => true, :uniqueness => true
  validates :name,
    :inclusion => {:in => self.dict, :message => 'cannot change protected name'},
    :if => lambda { |t| t.name_changed? && t.class.dict.include?(t.name_was) },
    :on => :update
  validate :taxonomy_cannot_be_changed_if_dependent_objects_present
  belongs_to :taxonomy
  has_many :species_listings
  has_many :change_types
  has_many :taxon_concepts

  before_destroy :check_destroy_allowed

  private

  def taxonomy_cannot_be_changed_if_dependent_objects_present
    if taxonomy_id_changed? && has_dependent_objects?
      errors.add(:taxonomy, "cannot be changed once dependent objects are attached")
      return false
    end
  end

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
    !(species_listings.count == 0 &&
    change_types.count == 0 &&
    taxon_concepts.count == 0)
  end

  def has_protected_name?
    self.class.dict.include? self.name
  end

end
