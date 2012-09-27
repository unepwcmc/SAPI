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
#

class TaxonConcept < ActiveRecord::Base
  # include PgArrayParser
  # attr_accessible :lft, :parent_id, :rgt, :rank_id, :parent_id,
    # :designation_id, :taxon_name_id, :fully_covered,
    # :data
  # attr_accessor :listing_history
  serialize :data, ActiveRecord::Coders::Hstore
  serialize :listing, ActiveRecord::Coders::Hstore
# 
  # belongs_to :rank
  # belongs_to :designation
  # belongs_to :taxon_name
  # has_many :relationships, :class_name => 'TaxonRelationship',
    # :dependent => :destroy
  # has_many :related_taxon_concepts, :class_name => 'TaxonConcept',
    # :through => :relationships
  # has_many :taxon_concept_geo_entities
  # has_many :geo_entities, :through => :taxon_concept_geo_entities
  # has_many :listing_changes
  # has_many :species_listings, :through => :listing_changes
  # has_many :taxon_commons, :dependent => :destroy
  # has_many :common_names, :through => :taxon_commons
  # has_and_belongs_to_many :references, :join_table => :taxon_concept_references

  # scope :with_all, joins("LEFT JOIN taxon_concepts_mview ON taxon_concepts.id = taxon_concepts_mview.id")
  # scope :with_standard_references, select(:std_ref_ary).joins(
    # <<-SQL
    # LEFT JOIN (
      # WITH RECURSIVE q AS (
        # SELECT h, h.id, ARRAY_AGG(reference_id) AS std_ref_ary
        # FROM taxon_concepts h
        # LEFT JOIN taxon_concept_references
        # ON h.id = taxon_concept_references.taxon_concept_id
          # AND taxon_concept_references.data->'usr_is_std_ref' = 't'
        # WHERE h.parent_id IS NULL
        # GROUP BY h.id
# 
        # UNION ALL
# 
        # SELECT hi, hi.id,
          # CASE
            # WHEN (hi.data->'usr_no_std_ref')::BOOLEAN = 't' THEN ARRAY[]::INTEGER[]
            # ELSE std_ref_ary || reference_id
          # END
        # FROM q
        # JOIN taxon_concepts hi ON hi.parent_id = (q.h).id
        # LEFT JOIN taxon_concept_references
        # ON hi.id = taxon_concept_references.taxon_concept_id
          # AND taxon_concept_references.data->'usr_is_std_ref' = 't'
      # )
      # SELECT id AS taxon_concept_id_sr,
      # ARRAY(SELECT DISTINCT * FROM UNNEST(std_ref_ary) s WHERE s IS NOT NULL)
      # AS std_ref_ary
      # FROM q
    # ) standard_references ON taxon_concepts.id = standard_references.taxon_concept_id_sr
    # SQL
  # )
# 

# 
  # acts_as_nested_set

# 
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

# 

# 
# 

# 

# 

# 
  # #note this will probably return external reference ids in the future
  # def standard_references
    # me = unless respond_to?(:std_ref_ary)
      # TaxonConcept.with_standard_references.where(:id => self.id).first
    # else
      # self
    # end
    # if me.respond_to?(:std_ref_ary)
      # parse_pg_array(me.std_ref_ary || '').compact.map do |e|
        # e.force_encoding('utf-8')
      # end.map(&:to_i)
    # else
      # []
    # end
  # end

end
