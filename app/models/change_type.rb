# == Schema Information
#
# Table name: change_types
#
#  id              :integer          not null, primary key
#  display_name_en :text             not null
#  display_name_es :text
#  display_name_fr :text
#  name            :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  designation_id  :integer          not null
#
# Indexes
#
#  index_change_types_on_designation_id                      (designation_id)
#  index_change_types_on_designation_id_and_display_name_en  (designation_id,display_name_en) UNIQUE
#  index_change_types_on_designation_id_and_name             (designation_id,name) UNIQUE
#  index_change_types_on_display_name_en_and_designation_id  (display_name_en,designation_id) UNIQUE
#  index_change_types_on_name_and_designation_id             (name,designation_id) UNIQUE
#
# Foreign Keys
#
#  change_types_designation_id_fk  (designation_id => designations.id)
#

class ChangeType < ApplicationRecord
  include Deletable
  extend Mobility
  # Migrated to controller (Strong Parameters)
  # attr_accessible :name, :display_name_en, :display_name_es, :display_name_fr,
  #   :designation_id
  include Dictionary
  build_dictionary :addition, :deletion, :reservation, :reservation_withdrawal, :exception

  translates :display_name

  belongs_to :designation
  has_many :listing_changes

  validates :name, presence: true, uniqueness: { scope: :designation_id }
  validates :display_name_en, presence: true, uniqueness: { scope: :designation_id }

  def abbreviation
    self.name.split('_').
      pluck(0..2).join('-')
  end

  def print_name
    self.name.titleize
  end

private

  def dependent_objects_map
    {
      'listing changes' => listing_changes
    }
  end
end
