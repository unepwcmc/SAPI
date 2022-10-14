class EuCountryDate < ActiveRecord::Base
  belongs_to :geo_entity
  validates :geo_entity, :presence => true
  validate :is_country

  private

  def is_country
    unless self.geo_entity.is_country?
      error.add(:geo_entity, "Must be a country")
    end
  end
end
