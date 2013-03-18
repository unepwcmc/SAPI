# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Event < ActiveRecord::Base
  attr_accessible :name, :designation_id, :description, :url, :effective_at
  belongs_to :designation
  has_many :listing_changes
  validates :name, :presence => true, :uniqueness => true
  validates :url, :format => URI::regexp(%w(http https)), :allow_nil => true

  def effective_at_formatted
    effective_at && effective_at.strftime("%d/%m/%Y")
  end

  def can_be_deleted?
    listing_changes.count == 0
  end

  def self.search query
    if query
      where("UPPER(name) LIKE UPPER(?)", "%#{query}%")
    else
      scoped
    end
  end
end
