# == Schema Information
#
# Table name: designations
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  taxonomy_id :integer          default(1), not null
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
  has_many :events
  has_many :listing_changes, :through => :change_types

  def is_cites?
    name == CITES
  end

  def is_eu?
    name == EU
  end

  def can_be_deleted?
    !has_protected_name? && !has_dependent_objects?
  end

  private

  def taxonomy_cannot_be_changed_if_dependent_objects_present
    if taxonomy_id_changed? && has_dependent_objects?
      errors.add(:taxonomy, "cannot be changed once dependent objects are attached")
      return false
    end
  end

  def has_dependent_objects?
    !(species_listings.count == 0 &&
    change_types.count == 0)
  end

  def has_protected_name?
    self.class.dict.include? self.name
  end

end
