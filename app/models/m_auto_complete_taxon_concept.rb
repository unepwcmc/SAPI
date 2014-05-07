class MAutoCompleteTaxonConcept < ActiveRecord::Base
  include PgArrayParser
  self.table_name = :auto_complete_taxon_concepts_mview
  self.primary_key = :id
  scope :by_cites_eu_taxonomy, where(:taxonomy_is_cites_eu => true)
  scope :by_cms_taxonomy, where(:taxonomy_is_cites_eu => false)
  def matching_names
    parse_pg_array(read_attribute(:matching_names_ary))
  end
end