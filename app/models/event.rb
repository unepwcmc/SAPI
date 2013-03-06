class Event < ActiveRecord::Base
  attr_accessible :name
  validates :name, :presence => true, :uniqueness => true

  def self.search query
    where("UPPER(name) LIKE UPPER(?)", "%#{query}%")
  end
end
