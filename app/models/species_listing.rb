# == Schema Information
#
# Table name: species_listings
#
#  id             :integer          not null, primary key
#  abbreviation   :string(255)
#  name           :string(255)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  designation_id :integer          not null
#
# Indexes
#
#  index_species_listings_on_abbreviation_and_designation_id  (abbreviation,designation_id) UNIQUE
#  index_species_listings_on_designation_id                   (designation_id)
#  index_species_listings_on_designation_id_and_abbreviation  (designation_id,abbreviation) UNIQUE
#  index_species_listings_on_designation_id_and_name          (designation_id,name) UNIQUE
#  index_species_listings_on_name_and_designation_id          (name,designation_id) UNIQUE
#
# Foreign Keys
#
#  species_listings_designation_id_fk  (designation_id => designations.id)
#

class SpeciesListing < ApplicationRecord
  include Deletable
  # Migrated to controller (Strong Parameters)
  # attr_accessible :designation_id, :name, :abbreviation

  belongs_to :designation
  has_many :listing_changes

  validates :name, presence: true, uniqueness: { scope: :designation_id }
  validates :abbreviation, presence: true, uniqueness: { scope: :designation_id }

  def self.search(query)
    self.joins(:designation).ilike_search(
      query, [
        :name,
        :abbreviation,
        Designation.arel_table['name']
      ]
    )
  end

private

  def dependent_objects_map
    {
      'listing changes' => listing_changes
    }
  end
end
