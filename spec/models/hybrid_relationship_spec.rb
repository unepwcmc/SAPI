require 'spec_helper'

describe TaxonRelationship do
  context "when hybrid" do
    let(:parent) {
      create_cites_eu_genus(
        :taxon_name => create(:taxon_name, :scientific_name => 'Lolcatus')
      )
    }
    let!(:tc) {
      create_cites_eu_species(
        :parent_id => parent.id,
        :taxon_name => create(:taxon_name, :scientific_name => 'lolatus')
      )
    }
    let!(:another_tc) {
      create_cites_eu_species(
        :parent_id => parent.id,
        :taxon_name => create(:taxon_name, :scientific_name => 'lolcatus')
      )
    }

    let(:hybrid) {
      create_cites_eu_species(
        name_status: 'H',
        author_year: 'Hemulen 2013',
        scientific_name: 'Lolcatus lolatus x lolcatus'
      )
    }
    let(:another_hybrid) {
      create_cites_eu_species(
        name_status: 'H',
        author_year: 'Hemulen 2013',
        scientific_name: 'Lolcatus lolcatus x ?'
      )
    }
    let(:hybrid_rel) {
      build(
        :taxon_relationship,
        taxon_relationship_type: hybrid_relationship_type,
        taxon_concept_id: tc.id,
        other_taxon_concept_id: hybrid.id
      )
    }
    let(:another_hybrid_rel) {
      build(
        :taxon_relationship,
        taxon_relationship_type: hybrid_relationship_type,
        taxon_concept_id: another_tc.id,
        other_taxon_concept_id: hybrid.id
      )
    }
    specify {
      hybrid_rel.save
      tc.hybrids.map(&:full_name).should include('Lolcatus lolatus x lolcatus')
    }
    specify {
      hybrid_rel.save
      another_hybrid_rel.save
      hybrid_rel.other_taxon_concept = another_hybrid
      hybrid_rel.save
      tc.hybrids.map(&:full_name).should include('Lolcatus lolcatus x ?')
      another_tc.hybrids.map(&:full_name).should include('Lolcatus lolatus x lolcatus')
    }
  end
end
