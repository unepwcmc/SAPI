require 'spec_helper'

describe TaxonRelationship do
  context 'when synonymy' do
    let(:parent) do
      create_cites_eu_genus(
        taxon_name: create(:taxon_name, scientific_name: 'Lolcatus')
      )
    end
    let!(:tc) do
      create_cites_eu_species(
        parent_id: parent.id,
        taxon_name: create(:taxon_name, scientific_name: 'lolatus')
      )
    end
    let!(:another_tc) do
      create_cites_eu_species(
        parent_id: parent.id,
        taxon_name: create(:taxon_name, scientific_name: 'lolcatus')
      )
    end
    let(:synonym) do
      create_cites_eu_species(
        name_status: 'S',
        author_year: 'Hemulen 2013',
        scientific_name: 'Lolcatus lolus'
      )
    end
    let(:another_synonym) do
      create_cites_eu_species(
        name_status: 'S',
        author_year: 'Hemulen 2013',
        scientific_name: 'Lolcatus lolatus'
      )
    end
    let(:synonymy_rel) do
      build(
        :taxon_relationship,
        taxon_relationship_type: synonym_relationship_type,
        taxon_concept_id: tc.id,
        other_taxon_concept_id: synonym.id
      )
    end
    let(:another_synonymy_rel) do
      build(
        :taxon_relationship,
        taxon_relationship_type: synonym_relationship_type,
        taxon_concept_id: another_tc.id,
        other_taxon_concept_id: synonym.id
      )
    end
    specify do
      synonymy_rel.save
      expect(tc.synonyms.map(&:full_name)).to include('Lolcatus lolus')
    end
    specify do
      synonymy_rel.save
      another_synonymy_rel.save
      synonymy_rel.other_taxon_concept = another_synonym
      synonymy_rel.save
      expect(tc.synonyms.map(&:full_name)).to include('Lolcatus lolatus')
      expect(another_tc.synonyms.map(&:full_name)).to include('Lolcatus lolus')
    end
  end
end
