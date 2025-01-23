# == Schema Information
#
# Table name: preset_tags
#
#  id         :integer          not null, primary key
#  model      :string(255)
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_preset_tags_on_name_upper_model  (name, upper((model)::text)) UNIQUE
#

class PresetTag < ApplicationRecord
  include Deletable
  # Migrated to controller (Strong Parameters)
  # attr_accessible :model, :name

  TYPES = {
    Distribution: 'Distribution',
    TaxonConcept: 'TaxonConcept'
  }

  validates :name, presence: true, uniqueness: {
    scope: :model, case_sensitive: false
  }

  validates :model, inclusion: { in: TYPES.values }

  def can_be_deleted?
    ActsAsTaggableOn::Tag.where(name: name).joins(:taggings).limit(1).empty?
  end
end
