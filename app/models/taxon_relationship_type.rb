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
  SYNONYM = 'SYNONYM'

  def self.dict
    [CONTAINS, SYNONYM]
  end

end
