class Event < ActiveRecord::Base
  attr_accessible :name, :designation_id, :description, :url, :effective_at
  belongs_to :designation
  has_many :listing_changes
  validates :name, :presence => true, :uniqueness => true

  def effective_at_formatted
    effective_at && effective_at.strftime("%d/%m/%Y")
  end

  def can_be_deleted?
    listing_changes.count == 0
  end

end
