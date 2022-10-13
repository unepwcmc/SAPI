class EuCountryDate < ActiveRecord::Base
  attr_accessible :eu_accession_year, :eu_exit_year
  belongs_to :geo_entity
  validates :geo_entity, :presence => true

  private
  
  def is_country
    unless self.geo_entity.is_country?
      error.add(:geo_entity, "Must be a country")
    end
  end
end
