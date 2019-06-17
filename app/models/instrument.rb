# == Schema Information
#
# Table name: instruments
#
#  id             :integer          not null, primary key
#  designation_id :integer
#  name           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Instrument < ActiveRecord::Base
  attr_accessible :designation_id, :name

  validates :name, :presence => true, :uniqueness => { :scope => :designation_id }

  belongs_to :designation
  has_many :taxon_instruments

  def self.search(query)
    if query.present?
      where("UPPER(name) LIKE UPPER(:query)",
            :query => "%#{query}%")
    else
      all
    end
  end

  private

  def dependent_objects_map
    {
      'taxon instruments' => taxon_instruments
    }
  end

end
