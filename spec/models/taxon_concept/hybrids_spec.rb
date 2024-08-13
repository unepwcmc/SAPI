require 'spec_helper'

describe TaxonConcept do
  before(:each) { hybrid_relationship_type }
  describe :create do
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
    let(:hybrid) do
      create_cites_eu_species(
        name_status: 'H',
        author_year: 'Taxonomus 2013',
        taxon_name: create(:taxon_name, scientific_name: 'Lolcatus lolcatus x lolatus')
      )
    end
    let!(:hybrid_rel) do
      create(
        :taxon_relationship,
        taxon_relationship_type: hybrid_relationship_type,
        taxon_concept_id: tc.id,
        other_taxon_concept_id: hybrid.id
      )
    end
    context 'when new' do
      specify do
        expect(tc.has_hybrids?).to be_truthy
      end
      specify do
        expect(hybrid.is_hybrid?).to be_truthy
      end
      specify do
        expect(hybrid.has_hybrid_parents?).to be_truthy
      end
      specify do
        expect(hybrid.full_name).to eq('Lolcatus lolcatus x lolatus')
      end
    end
    context 'when duplicate' do
      let(:duplicate) do
        hybrid.dup
      end
      specify do
        expect do
          duplicate.save
        end.to change(TaxonConcept, :count).by(0)
      end
    end
    context 'when duplicate but author name different' do
      let(:duplicate) do
        res = hybrid.dup
        res.author_year = 'Hemulen 2013'
        res
      end
      specify do
        expect do
          duplicate.save
        end.to change(TaxonConcept, :count).by(1)
      end
    end
  end
end
