# == Schema Information
#
# Table name: taxon_relationship_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TaxonRelationshipType < ActiveRecord::Base
  attr_accessible :name

  CONTAINS = 'CONTAINS'
  HAS_SYNONYM = 'HAS_SYNONYM'

  def self.dict
    [CONTAINS, HAS_SYNONYM]
  end

end
