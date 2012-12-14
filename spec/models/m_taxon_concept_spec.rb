# == Schema Information
#
# Table name: taxon_concepts_mview
#
#  id                               :integer          primary key
#  parent_id                        :integer
#  designation_is_cites             :boolean
#  full_name                        :text
#  rank_name                        :text
#  cites_accepted                   :boolean
#  kingdom_position                 :integer
#  taxonomic_position               :text
#  kingdom_name                     :text
#  phylum_name                      :text
#  class_name                       :text
#  order_name                       :text
#  family_name                      :text
#  genus_name                       :text
#  species_name                     :text
#  subspecies_name                  :text
#  kingdom_id                       :integer
#  phylum_id                        :integer
#  class_id                         :integer
#  order_id                         :integer
#  family_id                        :integer
#  genus_id                         :integer
#  species_id                       :integer
#  subspecies_id                    :integer
#  cites_name_status                :string
#  cites_fully_covered              :boolean
#  cites_listed                     :boolean
#  cites_deleted                    :boolean
#  cites_excluded                   :boolean
#  cites_show                       :boolean
#  cites_i                          :boolean
#  cites_ii                         :boolean
#  cites_iii                        :boolean
#  current_listing                  :text
#  listing_updated_at               :datetime
#  specific_annotation_symbol       :text
#  generic_annotation_symbol        :text
#  generic_annotation_parent_symbol :text
#  author_year                      :string(255)
#  created_at                       :datetime
#  updated_at                       :datetime
#  taxon_concept_id_com             :integer
#  english_names_ary                :string
#  french_names_ary                 :string
#  spanish_names_ary                :string
#  taxon_concept_id_syn             :integer
#  synonyms_ary                     :string
#  synonyms_author_years_ary        :string
#  countries_ids_ary                :string
#  standard_references_ids_ary      :string
#  dirty                            :boolean
#  expiry                           :datetime
#

require 'spec_helper'

describe MTaxonConcept do
  include_context "Canis lupus"
  context "search by cites populations" do
    context "when Nepal" do
      specify do
        MTaxonConcept.by_cites_populations_and_appendices([], [nepal.id]).
        should include(@species)
      end
    end
    context "when Poland" do
      specify do
        MTaxonConcept.by_cites_populations_and_appendices([], [poland.id]).
        should include(@species)
      end
    end
  end
  context "search by cites appendices" do
    context "when App I" do
      specify do
        MTaxonConcept.by_cites_appendices(['I']).should include(@species)
      end
    end
    context "when App II" do
      specify do
        MTaxonConcept.by_cites_appendices(['II']).should include(@species)
      end
    end
    context "when App III" do
      specify do
        MTaxonConcept.by_cites_appendices(['III']).should_not include(@species)
      end
    end
  end
  context "search by cites populations and appendices" do
    context "when Nepal" do
      context "when App I" do
        specify do
          MTaxonConcept.
          by_cites_populations_and_appendices([], [nepal.id], ['I']).
          should include(@species)
        end
      end
      context "when App II" do
        specify do
          puts MTaxonConcept.
          by_cites_populations_and_appendices([], [nepal.id], ['II']).to_sql
          MTaxonConcept.
          by_cites_populations_and_appendices([], [nepal.id], ['II']).
          should_not include(@species)
        end
      end
    end
    context "when Poland" do
      context "when App I" do
        specify do
          MTaxonConcept.
          by_cites_populations_and_appendices([], [poland.id], ['I']).
          should_not include(@species)
        end
      end
      context "when App II" do
        specify do

          MTaxonConcept.
          by_cites_populations_and_appendices([], [poland.id], ['II']).
          should include(@species)
        end
      end
    end
    context "when Poland or Nepal" do
      context "when App I" do
        specify do
          MTaxonConcept.
          by_cites_populations_and_appendices([], [poland.id, nepal.id], ['I']).
          should include(@species)
        end
      end
      context "when App II" do
        specify do
puts MTaxonConcept.
          by_cites_populations_and_appendices([], [poland.id, nepal.id], ['II']).to_sql
          MTaxonConcept.
          by_cites_populations_and_appendices([], [poland.id, nepal.id], ['II']).
          should include(@species)
        end
      end
    end
    context "when App I or II" do
      context "when Poland" do
        specify do
          MTaxonConcept.
          by_cites_populations_and_appendices([], [poland.id], ['I', 'II']).
          should include(@species)
        end
      end
      context "when Nepal" do
        specify do

          MTaxonConcept.
          by_cites_populations_and_appendices([], [nepal.id], ['I', 'II']).
          should include(@species)
        end
      end
    end
  end
end
