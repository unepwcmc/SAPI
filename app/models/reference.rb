# == Schema Information
#
# Table name: references
#
#  id            :integer          not null, primary key
#  author        :string(255)
#  citation      :text             not null
#  legacy_type   :string(255)
#  publisher     :text
#  title         :text
#  year          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :integer
#  legacy_id     :integer
#  updated_by_id :integer
#
# Foreign Keys
#
#  references_created_by_id_fk  (created_by_id => users.id)
#  references_updated_by_id_fk  (updated_by_id => users.id)
#

class Reference < ApplicationRecord
  include Deletable
  include TrackWhoDoesIt
  # Migrated to controller (Strong Parameters)
  # attr_accessible :citation, :created_by_id, :updated_by_id

  validates :citation, presence: true
  has_many :taxon_concept_references
  has_many :distribution_references

  def self.search(query)
    if query.present?
      where('UPPER(citation) LIKE UPPER(:query)',
        query: "%#{query}%")
    else
      all
    end
  end

  private

  def dependent_objects_map
    {
      'taxon references' => taxon_concept_references,
      'distribution references' => distribution_references
    }
  end

end
