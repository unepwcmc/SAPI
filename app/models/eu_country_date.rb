# == Schema Information
#
# Table name: eu_country_dates
#
#  id                :integer          not null, primary key
#  eu_accession_year :integer
#  eu_exit_year      :integer
#  created_at        :datetime
#  updated_at        :datetime
#  geo_entity_id     :integer
#
class EuCountryDate < ApplicationRecord
  # Used by rake task.
  # attr_accessible :eu_accession_year, :eu_exit_year, :geo_entity

  belongs_to :geo_entity
  validates :eu_accession_year, presence: true
  validate :is_country

private

  def is_country
    unless self.geo_entity.is_country?
      error.add(:geo_entity, 'Must be a country')
    end
  end
end
