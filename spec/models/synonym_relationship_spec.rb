require 'spec_helper'

describe TaxonRelationship do
  context "when synonymy" do
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
    let(:synonym) {
      create_cites_eu_species(
        name_status: 'S',
        author_year: 'Hemulen 2013',
        scientific_name: 'Lolcatus lolus'
      )
    }
    let(:another_synonym) {
      create_cites_eu_species(
        name_status: 'S',
        author_year: 'Hemulen 2013',
        scientific_name: 'Lolcatus lolatus'
      )
    }
    let(:synonymy_rel) {
      build(
        :taxon_relationship,
        taxon_relationship_type: synonym_relationship_type,
        taxon_concept_id: tc.id,
        other_taxon_concept_id: synonym.id
      )
    }
    let(:another_synonymy_rel) {
      build(
        :taxon_relationship,
        taxon_relationship_type: synonym_relationship_type,
        taxon_concept_id: another_tc.id,
        other_taxon_concept_id: synonym.id
      )
    }
    specify {
      synonymy_rel.save
      tc.synonyms.map(&:full_name).should include('Lolcatus lolus')
    }
    specify {
      synonymy_rel.save
      another_synonymy_rel.save
      synonymy_rel.other_taxon_concept = another_synonym
      synonymy_rel.save
      tc.synonyms.map(&:full_name).should include('Lolcatus lolatus')
      another_tc.synonyms.map(&:full_name).should include('Lolcatus lolus')
    }
  end
end
