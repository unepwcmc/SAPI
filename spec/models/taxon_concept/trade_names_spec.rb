require 'spec_helper'

describe TaxonConcept do
  before(:each) { trade_name_relationship_type }
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
    let(:trade_name) do
      create_cites_eu_species(
        name_status: 'T',
        author_year: 'Taxonomus 2014',
        taxon_name: create(:taxon_name, scientific_name: 'Lolcatus lolus')
      )
    end
    let!(:trade_name_rel) do
      create(:taxon_relationship,
        taxon_relationship_type: trade_name_relationship_type,
        taxon_concept_id: tc.id,
        other_taxon_concept_id: trade_name.id
      )
    end
    context 'when new' do
      specify do
        expect(tc.has_trade_names?).to be_truthy
      end
      specify do
        expect(trade_name.is_trade_name?).to be_truthy
      end
      specify do
        expect(trade_name.has_accepted_names_for_trade_name?).to be_truthy
      end
      specify do
        expect(trade_name.full_name).to eq('Lolcatus lolus')
      end
    end
    context 'when duplicate' do
      let(:duplicate) do
        trade_name.dup
      end
      specify do
        expect do
          duplicate.save
        end.to change(TaxonConcept, :count).by(0)
      end
    end
    context 'when duplicate but author name different' do
      let(:duplicate) do
        res = trade_name.dup
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
        @trade_name = create_cites_eu_subspecies(
          parent_id: tc.id,
          name_status: 'T',
          author_year: 'Taxonomus 2013',
          scientific_name: 'Lolcatus lolus furiatus'
        )
        create(
          :taxon_relationship,
          taxon_relationship_type: trade_name_relationship_type,
          taxon_concept: @subspecies,
          other_taxon_concept: @trade_name
        )
      end
      # should not modify a trade_name's full name when saving
      specify { expect(@trade_name.full_name).to eq('Lolcatus lolus furiatus') }
      context 'overnight calculations' do
        before(:each) do
          SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
        end
        # should not modify a trade_name's full name overnight
        specify { expect(@trade_name.reload.full_name).to eq('Lolcatus lolus furiatus') }
      end
    end
  end
end
