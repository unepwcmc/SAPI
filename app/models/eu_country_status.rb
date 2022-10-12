class EuCountryStatus < ActiveRecord::Base
	attr_accessible :eu_accession_year, :eu_exit_year
	belongs_to :geo_entity
	validates :geo_entity, :presence => true
end
