require 'spec_helper'

describe TaxonConcept do
  before(:each) { synonym_relationship_type }
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
    let(:synonym) do
      create_cites_eu_species(
        name_status: 'S',
        author_year: 'Taxonomus 2013',
        taxon_name: create(:taxon_name, scientific_name: 'Lolcatus lolus')
      )
    end
    let!(:synonym_rel) do
      create(
        :taxon_relationship,
        taxon_relationship_type: synonym_relationship_type,
        taxon_concept_id: tc.id,
        other_taxon_concept_id: synonym.id
      )
    end
    context 'when new' do
      specify do
        expect(tc.has_synonyms?).to be_truthy
      end
      specify do
        expect(synonym.is_synonym?).to be_truthy
      end
      specify do
        expect(synonym.has_accepted_names?).to be_truthy
      end
      specify do
        expect(synonym.full_name).to eq('Lolcatus lolus')
      end
    end
    context 'when duplicate' do
      let(:duplicate) do
        synonym.dup
      end
      specify do
        expect do
          duplicate.save
        end.to change(TaxonConcept, :count).by(0)
      end
    end
    context 'when duplicate but author name different' do
      let(:duplicate) do
        res = synonym.dup
        res.author_year = 'Hemulen 2013'
        res
      end
      specify do
        expect do
          duplicate.save
        end.to change(TaxonConcept, :count).by(1)
      end
    end
    context 'when has accepted parent' do
      before(:each) do
        @subspecies = create_cites_eu_subspecies(
          parent: tc,
          taxon_name: create(:taxon_name, scientific_name: 'perfidius')
        )
        @synonym = create_cites_eu_subspecies(
          parent_id: tc.id,
          name_status: 'S',
          author_year: 'Taxonomus 2013',
          scientific_name: 'Lolcatus lolus furiatus'
        )
        create(
          :taxon_relationship,
          taxon_relationship_type: synonym_relationship_type,
          taxon_concept: @subspecies,
          other_taxon_concept: @synonym
        )
      end
      # should not modify a synonym's full name when saving
      specify { expect(@synonym.full_name).to eq('Lolcatus lolus furiatus') }
      context 'overnight calculations' do
        before(:each) do
          SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
        end
        # should not modify a synonym's full name overnight
        specify { expect(@synonym.reload.full_name).to eq('Lolcatus lolus furiatus') }
      end
    end
  end
end
