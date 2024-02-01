require 'spec_helper'
describe Trade::ReportedTaxonConceptResolver do

  context "resolving trade names" do
    before(:each) do
      @accepted_name = create_cites_eu_species
      @trade_name = create_cites_eu_species(
        :name_status => 'T'
      )
      create(
        :taxon_relationship,
        :taxon_concept => @accepted_name,
        :other_taxon_concept => @trade_name,
        :taxon_relationship_type => trade_name_relationship_type
      )
    end
    let(:resolver) {
      Trade::ReportedTaxonConceptResolver.new(@trade_name.id)
    }
    specify { expect(resolver.accepted_taxa).to include(@accepted_name) }
  end

  context "resolving synonyms" do
    before(:each) do
      @accepted_name = create_cites_eu_species
      @synonym = create_cites_eu_species(
        :name_status => 'S'
      )
      create(
        :taxon_relationship,
        :taxon_concept => @accepted_name,
        :other_taxon_concept => @synonym,
        :taxon_relationship_type => synonym_relationship_type
      )
    end
    let(:resolver) {
      Trade::ReportedTaxonConceptResolver.new(@synonym.id)
    }
    specify { expect(resolver.accepted_taxa).to include(@accepted_name) }
  end

  context "resolving accepted names" do
    before(:each) do
      @accepted_name = create_cites_eu_species
    end
    let(:resolver) {
      Trade::ReportedTaxonConceptResolver.new(@accepted_name.id)
    }
    specify { expect(resolver.accepted_taxa).to include(@accepted_name) }
  end

end
