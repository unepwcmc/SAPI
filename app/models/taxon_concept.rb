# == Schema Information
#
# Table name: taxon_concepts
#
#  id             :integer          not null, primary key
#  parent_id      :integer
#  lft            :integer
#  rgt            :integer
#  rank_id        :integer          not null
#  designation_id :integer          not null
#  taxon_name_id  :integer          not null
#  legacy_id      :integer
#  legacy_type    :string(255)
#  data           :hstore
#  listing        :hstore
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  author_year    :string(255)
#  notes          :text
#

class TaxonConcept < ActiveRecord::Base
  attr_accessible :lft, :parent_id, :rgt, :rank_id, :parent_id,
    :designation_id, :taxon_name_id, :data, :legacy_id, :legacy_type

  serialize :data, ActiveRecord::Coders::Hstore
  serialize :listing, ActiveRecord::Coders::Hstore

  belongs_to :rank
  belongs_to :designation
  belongs_to :taxon_name
  has_many :relationships, :class_name => 'TaxonRelationship',
    :dependent => :destroy
  has_many :related_taxon_concepts, :class_name => 'TaxonConcept',
    :through => :relationships
  has_many :taxon_concept_geo_entities
  has_many :geo_entities, :through => :taxon_concept_geo_entities
  has_many :listing_changes
  has_many :species_listings, :through => :listing_changes
  has_many :taxon_commons, :dependent => :destroy
  has_many :common_names, :through => :taxon_commons
  has_and_belongs_to_many :references, :join_table => :taxon_concept_references

  acts_as_nested_set

end
