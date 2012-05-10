# == Schema Information
#
# Table name: taxon_relationships
#
#  id                         :integer         not null, primary key
#  taxon_concept_id           :integer         not null
#  other_taxon_concept_id     :integer         not null
#  taxon_relationship_type_id :integer         not null
#  created_at                 :datetime        not null
#  updated_at                 :datetime        not null
#

class TaxonRelationship < ActiveRecord::Base
  attr_accessible :taxon_concept_id, :other_taxon_concept_id, :taxon_relationship_type_id
  belongs_to :taxon_relationship_type
  belongs_to :related_taxon_concept, :foreign_key => :other_taxon_concept_id
end
