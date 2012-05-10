# == Schema Information
#
# Table name: taxon_concepts
#
#  id             :integer         not null, primary key
#  parent_id      :integer
#  lft            :integer
#  rgt            :integer
#  rank_id        :integer         not null
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  spcrecid       :integer
#  depth          :integer
#  designation_id :integer         not null
#  taxon_name_id  :integer         not null
#

class TaxonConcept < ActiveRecord::Base
  attr_accessible :lft, :parent_id, :rgt, :rank_id, :parent_id,
    :designation_id, :taxon_name_id
  belongs_to :rank
  belongs_to :designation
  belongs_to :taxon_name
  has_many :relationships, :class_name => 'TaxonRelationship', :dependent => :destroy
  has_many :related_taxon_concepts, :class_name => 'TaxonConcept', :through => :relationships

  acts_as_nested_set

  def wholes
    related_taxon_concepts.includes(:relationships => :taxon_relationship_type).where(:taxon_relationship_types => {:name => 'has_part'})
  end
  def parts
    related_taxon_concepts.includes(:relationships => :taxon_relationship_type).where(:taxon_relationship_types => {:name => 'is_part_of'})
  end
  def synonyms
    related_taxon_concepts.includes(:relationships => :taxon_relationship_type).where(:taxon_relationship_types => {:name => 'is_synonym'})
  end
end
