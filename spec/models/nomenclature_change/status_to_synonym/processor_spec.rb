require 'spec_helper'

describe NomenclatureChange::StatusToSynonym::Processor do
  include_context 'status_change_definitions'

  before(:each){ synonym_relationship_type }
  let(:processor){ NomenclatureChange::StatusToSynonym::Processor.new(status_change) }
  let(:primary_output_taxon_concept){ status_change.primary_output.taxon_concept }
  let(:secondary_output_taxon_concept){ status_change.secondary_output.taxon_concept }

  describe :run do
    context "from accepted name" do
      let(:status_change){ a_to_s_with_input_and_secondary_output }
      before(:each){
        @shipment = create(:shipment,
          taxon_concept: primary_output_taxon_concept,
          reported_taxon_concept: primary_output_taxon_concept
        )
        processor.run
      }
      specify{ expect(primary_output_taxon_concept).to be_is_synonym }
      specify{ expect(primary_output_taxon_concept.accepted_names).to include(secondary_output_taxon_concept) }
      specify{ expect(primary_output_taxon_concept.shipments).to be_empty }
      specify{ expect(primary_output_taxon_concept.reported_shipments).to include(@shipment) }
      specify{ expect(secondary_output_taxon_concept.shipments).to include(@shipment) }
    end
    context "from trade name" do
      let(:input_species){ trade_name }
      let(:status_change){ t_to_s_with_primary_and_secondary_output }
      before(:each){
        @shipment = create(:shipment,
          taxon_concept: accepted_name,
          reported_taxon_concept: primary_output_taxon_concept
        )
        processor.run
      }
      specify{ expect(primary_output_taxon_concept).to be_is_synonym }
      specify{ expect(primary_output_taxon_concept.accepted_names).to include(secondary_output_taxon_concept) }
      specify{ expect(primary_output_taxon_concept.accepted_names_for_trade_name).to be_empty }
      specify{ expect(primary_output_taxon_concept.shipments).to be_empty }
      specify{ expect(primary_output_taxon_concept.reported_shipments).to include(@shipment) }
      specify{ expect(secondary_output_taxon_concept.shipments).to include(@shipment) }
    end
  end

end
