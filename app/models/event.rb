class Event < ActiveRecord::Base
  attr_accessible :name, :designation_id, :description, :url, :effective_at
  belongs_to :designation
  validates :name, :presence => true, :uniqueness => true

  def effective_at_formatted
    effective_at && effective_at.strftime("%d/%m/%y")
  end

end
