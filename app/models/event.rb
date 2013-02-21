class Event < ActiveRecord::Base
  attr_accessible :name
  belongs_to :designation
  validates :name, :presence => true, :uniqueness => true
end
