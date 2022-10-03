require 'spec_helper'

describe NomenclatureChange::FullReassignment do

  describe 'process' do
    let(:old_tc) { create_cites_eu_species }
    let(:new_tc) { create_cites_eu_species }
    subject { NomenclatureChange::FullReassignment.new(old_tc, new_tc) }

    context 'when distributions present' do
      before(:each) do
        create(:distribution, taxon_concept: old_tc)
        subject.process
      end
      specify { expect(new_tc.distributions.count).to eq(1) }
    end

    context 'when references present' do
      before(:each) do
        create(:taxon_concept_reference, taxon_concept: old_tc)
        subject.process
      end
      specify { expect(new_tc.taxon_concept_references.count).to eq(1) }
    end

    context 'when listing changes present' do
      before(:each) do
        create_cites_I_addition(taxon_concept: old_tc)
        subject.process
      end
      specify { expect(new_tc.listing_changes.count).to eq(1) }
    end

    context 'when EU Opinions present' do
      before(:each) do
        @eu_regulation = create(:ec_srg)
        create(:eu_opinion, taxon_concept: old_tc, start_event: @eu_regulation)
        subject.process
      end
      specify { expect(new_tc.eu_opinions.count).to eq(1) }
    end

    context 'when EU Suspensions present' do
      before(:each) do
        create(:eu_suspension, taxon_concept: old_tc)
        subject.process
      end
      specify { expect(new_tc.eu_suspensions.count).to eq(1) }
    end

    context 'when CITES Quotas present' do
      before(:each) do
        create(:quota, taxon_concept: old_tc, geo_entity: create(:geo_entity))
        subject.process
      end
      specify { expect(new_tc.quotas.count).to eq(1) }
    end

    context 'when CITES Suspensions present' do
      before(:each) do
        create(:cites_suspension, taxon_concept: old_tc,
          start_notification: create(:cites_suspension_notification, :designation => cites)
        )
        subject.process
      end
      specify { expect(new_tc.cites_suspensions.count).to eq(1) }
    end

    context 'when common names present' do
      before(:each) do
        create(:taxon_common, taxon_concept: old_tc)
        subject.process
      end
      specify { expect(new_tc.taxon_commons.count).to eq(1) }
    end

    context 'when document citations present' do
      before(:each) do
        create(
          :document_citation_taxon_concept,
          taxon_concept: old_tc,
          document_citation: create(
            :document_citation,
            document: create(:document)
          )
        )
        subject.process
      end
      specify { expect(new_tc.document_citation_taxon_concepts.count).to eq(1) }
    end

  end

end
