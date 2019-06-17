# == Schema Information
#
# Table name: references
#
#  id            :integer          not null, primary key
#  title         :text
#  year          :string(255)
#  author        :string(255)
#  citation      :text             not null
#  publisher     :text
#  legacy_id     :integer
#  legacy_type   :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  updated_by_id :integer
#  created_by_id :integer
#

class Reference < ActiveRecord::Base
  track_who_does_it
  attr_accessible :citation, :created_by_id, :updated_by_id

  validates :citation, :presence => true
  has_many :taxon_concept_references
  has_many :distribution_references

  def self.search(query)
    if query.present?
      where("UPPER(citation) LIKE UPPER(:query)",
        :query => "%#{query}%")
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
