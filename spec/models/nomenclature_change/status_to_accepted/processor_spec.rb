require 'spec_helper'

describe NomenclatureChange::StatusToAccepted::Processor do
  include_context 'status_change_definitions'

  let(:accepted_name){ create_cites_eu_species }

  let(:trade_name){
    tc = create_cites_eu_species(name_status: 'T')
    create(:taxon_relationship,
      taxon_concept: accepted_name,
      other_taxon_concept: tc,
      taxon_relationship_type: trade_name_relationship_type
    )
    tc
  }

  let(:synonym){
    tc = create_cites_eu_species(name_status: 'S')
    create(:taxon_relationship,
      taxon_concept: accepted_name,
      other_taxon_concept: tc,
      taxon_relationship_type: synonym_relationship_type
    )
    tc
  }

  before(:each){ synonym_relationship_type }
  let(:processor){ NomenclatureChange::StatusToAccepted::Processor.new(status_change) }
  let(:primary_output_taxon_concept){ status_change.primary_output.taxon_concept }
  let(:secondary_output_taxon_concept){ status_change.secondary_output.taxon_concept }

  describe :run do
    context "from synonym" do
      let(:output_species){ secondary_output_taxon_concept }
      let(:s_to_a_with_input){
        create(:nomenclature_change_status_to_accepted,
          primary_output_attributes: {
            is_primary_output: true,
            taxon_concept_id: synonym.id,
            new_name_status: 'A'
          },
          input_attributes: { taxon_concept_id: input_species.id },
          status: NomenclatureChange::StatusToAccepted::RECEIVE
        ).reload
      }
      let(:status_change){ s_to_a_with_input }
      before(:each){
        @shipment = create(:shipment,
          taxon_concept: accepted_name,
          reported_taxon_concept: primary_output_taxon_concept
        )
        processor.run
      }
      specify{ expect(primary_output_taxon_concept.name_status).to eq('A') }
      specify{ expect(primary_output_taxon_concept.accepted_names).to be_empty }
      specify{ expect(primary_output_taxon_concept.shipments).to include(@shipment) }
      specify{ expect(primary_output_taxon_concept.reported_shipments).to include(@shipment) }
      specify{ expect(accepted_name.shipments).to be_empty }
    end
    context "from trade name" do
      let(:output_species){ secondary_output_taxon_concept }
      let(:s_to_a_with_input){
        create(:nomenclature_change_status_to_accepted,
          primary_output_attributes: {
            is_primary_output: true,
            taxon_concept_id: trade_name.id,
            new_name_status: 'A'
          },
          input_attributes: { taxon_concept_id: input_species.id },
          status: NomenclatureChange::StatusToAccepted::RECEIVE
        ).reload
      }
      let(:status_change){ s_to_a_with_input }
      before(:each){
        @shipment = create(:shipment,
          taxon_concept: accepted_name,
          reported_taxon_concept: primary_output_taxon_concept
        )
        processor.run
      }
      specify{ expect(primary_output_taxon_concept.name_status).to eq('A') }
      specify{ expect(primary_output_taxon_concept.accepted_names_for_trade_name).to be_empty }
      specify{ expect(primary_output_taxon_concept.shipments).to include(@shipment) }
      specify{ expect(primary_output_taxon_concept.reported_shipments).to include(@shipment) }
      specify{ expect(accepted_name.shipments).to be_empty }
    end
  end

end
