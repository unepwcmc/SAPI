# == Schema Information
#
# Table name: ranks
#
#  id         :integer         not null, primary key
#  name       :string(255)     not null
#  parent_id  :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Rank < ActiveRecord::Base
  attr_accessible :name, :parent_id

  KINGDOM = 'KINGDOM'
  PHYLUM  = 'PHYLUM'
  CLASS = 'CLASS'
  ORDER = 'ORDER'
  FAMILY = 'FAMILY'
  GENUS = 'GENUS'
  SPECIES = 'SPECIES'
  SUBSPECIES = 'SUBSPECIES'

  def self.dict
    [KINGDOM, PHYLUM, CLASS, ORDER, FAMILY, GENUS, SPECIES, SUBSPECIES]
  end

end
