require 'spec_helper'

describe TaxonRelationship do
  context 'when hybrid' do
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

    let(:hybrid) do
      create_cites_eu_species(
        name_status: 'H',
        author_year: 'Hemulen 2013',
        scientific_name: 'Lolcatus lolatus x lolcatus'
      )
    end
    let(:another_hybrid) do
      create_cites_eu_species(
        name_status: 'H',
        author_year: 'Hemulen 2013',
        scientific_name: 'Lolcatus lolcatus x ?'
      )
    end
    let(:hybrid_rel) do
      build(
        :taxon_relationship,
        taxon_relationship_type: hybrid_relationship_type,
        taxon_concept_id: tc.id,
        other_taxon_concept_id: hybrid.id
      )
    end
    let(:another_hybrid_rel) do
      build(
        :taxon_relationship,
        taxon_relationship_type: hybrid_relationship_type,
        taxon_concept_id: another_tc.id,
        other_taxon_concept_id: hybrid.id
      )
    end
    specify do
      hybrid_rel.save
      expect(tc.hybrids.map(&:full_name)).to include('Lolcatus lolatus x lolcatus')
    end
    specify do
      hybrid_rel.save
      another_hybrid_rel.save
      hybrid_rel.other_taxon_concept = another_hybrid
      hybrid_rel.save
      expect(tc.hybrids.map(&:full_name)).to include('Lolcatus lolcatus x ?')
      expect(another_tc.hybrids.map(&:full_name)).to include('Lolcatus lolatus x lolcatus')
    end
  end
end
