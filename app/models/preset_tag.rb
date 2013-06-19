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
    :TaxonConcept => 'TaxonConcept',
    :Distribution => 'Distribution'
  }

  validates :name, :presence => true
  validates :model, :inclusion => { :in => TYPES.values }
end
