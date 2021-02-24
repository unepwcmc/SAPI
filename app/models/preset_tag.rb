# == Schema Information
#
# Table name: preset_tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  model      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PresetTag < ActiveRecord::Base
  attr_accessible :model, :name

  TYPES = {
    :Distribution => 'Distribution',
    :TaxonConcept => 'TaxonConcept'
  }

  validates :name, :presence => true, :uniqueness => {
    :scope => :model, :case_sensitive => false
  }
  validates :model, :inclusion => { :in => TYPES.values }

  def self.search(query)
    if query.present?
      where("UPPER(name) LIKE UPPER(:query) OR
        UPPER(model) LIKE UPPER(:query)",
        :query => "%#{query}%")
    else
      all
    end
  end

  def can_be_deleted?
    ActsAsTaggableOn::Tag.where(:name => name).joins(:taggings).limit(1).empty?
  end
end
