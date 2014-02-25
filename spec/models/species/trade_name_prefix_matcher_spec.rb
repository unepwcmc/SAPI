require 'spec_helper'
describe Species::TaxonConceptPrefixMatcher do
  before(:each) do
    @accepted_name = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Pavona')
    )
    @trade_name = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Pavona minor'),
      :name_status => 'T'
    )
    create(:taxon_relationship,
      :taxon_concept => @accepted_name,
      :other_taxon_concept => @trade_name,
      :taxon_relationship_type => create(
        :taxon_relationship_type,
        :name => TaxonRelationshipType::HAS_TRADE_NAME
      )
    )
    Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    @accepted_name = MTaxonConcept.find(@accepted_name.id)
    @trade_name = MTaxonConcept.find(@trade_name.id)
  end
  describe :results do
    context "when searching for trade name" do
      context "when trade visibility" do
        subject {
          Species::TaxonConceptPrefixMatcher.new({
            :taxon_concept_query => 'Pavona',
            :ranks => [],
            :visibility => :trade
          })
        }
        specify { subject.results.should_not include(@trade_name) }
        specify { subject.results.should include(@accepted_name) }
      end
      context "when trade internal visibility" do
        subject {
          Species::TaxonConceptPrefixMatcher.new({
            :taxon_concept_query => 'Pavona',
            :ranks => [],
            :visibility => :trade_internal
          })
        }
        specify { subject.results.should include(@trade_name) }
        specify { subject.results.should include(@accepted_name) }
      end
      context "when speciesplus visibility" do
        subject {
          Species::TaxonConceptPrefixMatcher.new({
            :taxon_concept_query => 'Pavona',
            :ranks => []
          })
        }
        specify { subject.results.should_not include(@trade_name) }
        specify { subject.results.should include(@accepted_name) }
      end
    end
  end
end