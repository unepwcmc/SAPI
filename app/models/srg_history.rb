class SrgHistory < ActiveRecord::Base
  attr_accessible :name, :tooltip

  has_many :eu_decisions

  validates :name, presence: true, uniqueness: true
end
