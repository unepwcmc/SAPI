class SrgHistory < ActiveRecord::Base
  # Migrated to controller (Strong Parameters)
  # attr_accessible :name, :tooltip

  has_many :eu_decisions

  validates :name, presence: true, uniqueness: true
end
