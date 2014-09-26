# == Schema Information
#
# Table name: taxon_concept_view_stats_view
#
#  id               :text
#  species          :text
#  taxonomy         :text
#  number_of_visits :integer
#

class TaxonConceptViewStats < ActiveRecord::Base
  self.table_name = :taxon_concept_view_stats_view
  scope :cites_eu, where(taxonomy: Taxonomy::CITES_EU)
  scope :cms, where(taxonomy: Taxonomy::CMS)
end
