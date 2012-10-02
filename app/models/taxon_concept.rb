# == Schema Information
#
# Table name: taxon_concepts
#
#  id             :integer          not null, primary key
#  parent_id      :integer
#  lft            :integer
#  rgt            :integer
#  rank_id        :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  designation_id :integer          not null
#  taxon_name_id  :integer          not null
#  legacy_id      :integer
#  data           :hstore
#  fully_covered  :boolean          default(TRUE), not null
#  listing        :hstore
#  legacy_type    :string(255)
#

class TaxonConcept < ActiveRecord::Base
  attr_accessible :lft, :parent_id, :rgt, :rank_id, :parent_id,
    :designation_id, :taxon_name_id, :fully_covered,
    :data

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

  # #here go the CITES listing flags
  # [
    # :cites_listed,#taxon is listed explicitly
    # :usr_cites_exclusion,#taxon is excluded from it's parent's listing
    # :cites_exclusion,#taxon's ancestor is excluded from it's parent's listing
    # :cites_del,#taxon has been deleted from appendices
    # :cites_show#@taxon should be shown in checklist even if NC
  # ].each do |attr_name|
    # define_method(attr_name) do
      # listing && case listing[attr_name.to_s]
        # when 't'
          # true
        # when 'f'
          # false
        # else
          # nil
      # end
    # end
  # end

end
