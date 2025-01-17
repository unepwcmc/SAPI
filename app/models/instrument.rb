# == Schema Information
#
# Table name: instruments
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  designation_id :integer
#
# Indexes
#
#  index_instruments_on_designation_id           (designation_id)
#  index_instruments_on_designation_id_and_name  (designation_id,name) UNIQUE
#  index_instruments_on_name_and_designation_id  (name,designation_id) UNIQUE
#
# Foreign Keys
#
#  instruments_designation_id_fk  (designation_id => designations.id)
#

class Instrument < ApplicationRecord
  include Deletable
  # Migrated to controller (Strong Parameters)
  # attr_accessible :designation_id, :name

  validates :name, presence: true, uniqueness: { scope: :designation_id }

  belongs_to :designation
  has_many :taxon_instruments

private

  def dependent_objects_map
    {
      'taxon instruments' => taxon_instruments
    }
  end
end
