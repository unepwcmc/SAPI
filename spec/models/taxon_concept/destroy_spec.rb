require 'spec_helper'

describe TaxonConcept do
  describe :destroy do
    context 'general' do
      before { @taxon_concept = create_cms_species }

      context 'when no dependent objects attached' do
        specify { expect(@taxon_concept.destroy).to be_truthy }
      end

      context 'when distributions' do
        before { create(:distribution, taxon_concept: @taxon_concept) }

        specify { expect(@taxon_concept.destroy).to be_truthy }
      end

      context 'when common names' do
        before { create(:taxon_common, taxon_concept: @taxon_concept) }

        specify { expect(@taxon_concept.destroy).to be_truthy }
      end

      context 'when references' do
        before { create(:taxon_concept_reference, taxon_concept: @taxon_concept) }

        specify { expect(@taxon_concept.destroy).to be_truthy }
      end

      context 'when document citations' do
        before do
          create(:document_citation_taxon_concept, taxon_concept: @taxon_concept)
        end

        specify { expect(@taxon_concept.destroy).to be_falsey }
      end
    end

    context 'CMS' do
      before { @taxon_concept = create_cms_species }

      context 'when taxon instruments' do
        before { create(:taxon_instrument, taxon_concept: @taxon_concept) }

        specify { expect(@taxon_concept.destroy).to be_falsey }
      end
    end

    context 'CITES / EU' do
      before { @taxon_concept = create_cites_eu_species }

      context 'when listing changes' do
        before { create_cites_I_addition(taxon_concept: @taxon_concept) }

        specify { expect(@taxon_concept.destroy).to be_falsey }
      end

      context 'when CITES quotas' do
        before { create(:quota, taxon_concept: @taxon_concept, geo_entity: create(:geo_entity)) }

        specify { expect(@taxon_concept.destroy).to be_falsey }
      end

      context 'when CITES suspensions' do
        before { create(:cites_suspension, taxon_concept: @taxon_concept, start_notification: create(:cites_suspension_notification, designation: cites)) }

        specify { expect(@taxon_concept.destroy).to be_falsey }
      end

      context 'when EU opinions' do
        before { create(:eu_opinion, taxon_concept: @taxon_concept, start_event: create(:ec_srg)) }

        specify { expect(@taxon_concept.destroy).to be_falsey }
      end

      context 'when EU suspensions' do
        before { create(:eu_suspension, taxon_concept: @taxon_concept) }

        specify { expect(@taxon_concept.destroy).to be_falsey }
      end

      context 'when shipments' do
        before { create(:shipment, taxon_concept: @taxon_concept) }

        specify { expect(@taxon_concept.destroy).to be_falsey }
      end

      context 'when reported shipments' do
        before { create(:shipment, reported_taxon_concept: @taxon_concept) }

        specify { expect(@taxon_concept.destroy).to be_falsey }
      end
    end
  end
end
