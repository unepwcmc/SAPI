class Taxonomy < ActiveRecord::Base
  attr_accessible :name
  has_many :designations
  validates :name, :presence => true
  include Dictionary
  build_dictionary :wildlife_trade

  before_destroy :check_destroy_allowed

  private

  def check_destroy_allowed
    unless can_be_deleted?
      errors.add(:base, "not allowed")
      return false
    end
  end

  def can_be_deleted?
    !has_protected_name? &&
    designations.count == 0
  end

  def has_protected_name?
    Taxonomy.dict.include? self.name
  end

end
