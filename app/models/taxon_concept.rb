# == Schema Information
#
# Table name: taxon_concepts
#
#  id                   :integer         not null, primary key
#  parent_id            :integer
#  lft                  :integer
#  rgt                  :integer
#  rank_id              :integer         not null
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  spcrecid             :integer
#  depth                :integer
#  designation_id       :integer         not null
#  taxon_name_id        :integer         not null
#  legacy_id            :integer
#  inherit_distribution :boolean         default(TRUE), not null
#  inherit_legislation  :boolean         default(TRUE), not null
#  inherit_references   :boolean         default(TRUE), not null
#

class TaxonConcept < ActiveRecord::Base
  attr_accessible :lft, :parent_id, :rgt, :rank_id, :parent_id,
    :designation_id, :taxon_name_id
  belongs_to :rank
  belongs_to :designation
  belongs_to :taxon_name
  has_many :relationships, :class_name => 'TaxonRelationship',
    :dependent => :destroy
  has_many :related_taxon_concepts, :class_name => 'TaxonConcept',
    :through => :relationships
  has_many :taxon_concept_geo_entities
  has_many :geo_entities, :through => :taxon_concept_geo_entities

  scope :checklist, select('taxon_concepts.id, taxon_concepts.depth,
    taxon_concepts.lft, taxon_concepts.rgt, taxon_concepts.parent_id,
    taxon_names.scientific_name, ranks.name AS rank_name').
    joins(:taxon_name).
    joins(:rank)

  acts_as_nested_set

  def wholes
    related_taxon_concepts.includes(:relationships => :taxon_relationship_type).
    where(:taxon_relationship_types => {:name => 'has_part'})
  end
  def parts
    related_taxon_concepts.includes(:relationships => :taxon_relationship_type).
    where(:taxon_relationship_types => {:name => 'is_part_of'})
  end
  def synonyms
    related_taxon_concepts.includes(:relationships => :taxon_relationship_type).
    where(:taxon_relationship_types => {:name => 'is_synonym'})
  end

class << self
  # options is a hash like 'CITES REGION' => [1,2,3]
  def by_geo_entities(options)
    res = joins(:geo_entities => :geo_entity_type)
    conds = [[]]
    options.each do |k, v|
      conds[0] << "geo_entity_types.name = ? AND geo_entities.id = ?"
      conds << k
      conds << v
    end
    conds[0] = conds[0].join(' OR ')
    res.where(conds)
  end
end

end
