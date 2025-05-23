# == Schema Information
#
# Table name: taxonomies
#
#  id         :integer          not null, primary key
#  name       :string(255)      default("DEAFAULT TAXONOMY"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_taxonomies_on_name  (name) UNIQUE
#

class Taxonomy < ApplicationRecord
  include Deletable
  include Dictionary
  build_dictionary :cites_eu, :cms

  # Migrated to controller (Strong Parameters)
  # attr_accessible :name
  has_many :designations
  has_many :taxon_concepts

  validates :name, presence: true, uniqueness: true
  validates :name,
    inclusion: { in: self.dict, message: 'cannot change protected name' },
    if: lambda { |t| t.name_changed? && t.class.dict.include?(t.name_was) },
    on: :update

  def can_be_deleted?
    super && !has_protected_name?
  end

private

  def dependent_objects_map
    {
      'designations' => designations,
      'taxon concepts' => taxon_concepts
    }
  end

  def has_protected_name?
    self.class.dict.include? self.name
  end
end
