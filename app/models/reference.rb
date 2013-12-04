# == Schema Information
#
# Table name: references
#
#  id          :integer          not null, primary key
#  title       :text
#  year        :string(255)
#  author      :string(255)
#  citation    :text             not null
#  publisher   :text
#  legacy_id   :integer
#  legacy_type :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Reference < ActiveRecord::Base
  attr_accessible :citation

  validates :citation, :presence => true
  has_many :taxon_concept_references
  has_many :distribution_references

  def self.search query
    if query.present?
      where("UPPER(citation) LIKE UPPER(:query)",
        :query => "%#{query}%")
    else
      scoped
    end
  end

  def can_be_deleted?
    taxon_concept_references.count == 0 &&
    distribution_references.count == 0
  end
end
