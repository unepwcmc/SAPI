require 'spec_helper'

describe NomenclatureChange::StatusChange::Processor do
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
  let(:processor){ NomenclatureChange::StatusChange::Processor.new(status_change) }
  let(:primary_output_taxon_concept){ status_change.primary_output.taxon_concept }
  let(:secondary_output_taxon_concept){ status_change.secondary_output.taxon_concept }
  describe :run do
    context "when turns into synonym" do
      context "from accepted name" do
        let(:status_change){ status_downgrade_with_input_and_secondary_output }
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

        context "when swap" do
          let(:status_change){ status_downgrade_with_swap }
          specify{ expect(primary_output_taxon_concept).to be_is_synonym }
          specify{ expect(secondary_output_taxon_concept.name_status).to eq('A') }
          specify{ expect(primary_output_taxon_concept.accepted_names).to include(secondary_output_taxon_concept) }
        end
      end
      context "from trade name" do
        let(:input_species){ trade_name }
        let(:status_change){ status_downgrade_with_primary_output }
        before(:each){
          @shipment = create(:shipment,
            taxon_concept: accepted_name,
            reported_taxon_concept: primary_output_taxon_concept
          )
          processor.run
        }
        specify{ expect(primary_output_taxon_concept).to be_is_synonym }
        specify{ expect(primary_output_taxon_concept.accepted_names).to include(accepted_name) }
        specify{ expect(primary_output_taxon_concept.accepted_names_for_trade_name).to be_empty }
        specify{ expect(primary_output_taxon_concept.shipments).to be_empty }
        specify{ expect(primary_output_taxon_concept.reported_shipments).to include(@shipment) }
        specify{ expect(accepted_name.shipments).to include(@shipment) }

        context "when swap" do
          let(:status_downgrade_with_swap){
            create(:nomenclature_change_status_change,
              primary_output_attributes: {
                is_primary_output: true,
                taxon_concept_id: trade_name.id,
                new_name_status: 'S'
              },
              input_attributes: { taxon_concept_id: input_species.id },
              secondary_output_attributes: {
                is_primary_output: false,
                taxon_concept_id: synonym.id,
                new_name_status: 'T'
              },
              status: NomenclatureChange::StatusChange::RELAY_OR_SWAP
            ).reload
          }
          let(:status_change){ status_downgrade_with_swap }
          specify{ expect(primary_output_taxon_concept).to be_is_synonym }
          specify{ expect(secondary_output_taxon_concept).to be_is_trade_name }
          specify{ expect(primary_output_taxon_concept.accepted_names_for_trade_name).to be_empty }
          specify{ expect(primary_output_taxon_concept.accepted_names).to include(accepted_name) }
        end
      end
    end
    context "when turns into accepted name" do
      context "from synonym" do
        let(:output_species){ secondary_output_taxon_concept }
        let(:status_upgrade_with_input){
          create(:nomenclature_change_status_change,
            primary_output_attributes: {
              is_primary_output: true,
              taxon_concept_id: synonym.id,
              new_name_status: 'A'
            },
            input_attributes: { taxon_concept_id: input_species.id },
            status: NomenclatureChange::StatusChange::RECEIVE_OR_SWAP
          ).reload
        }
        let(:status_change){ status_upgrade_with_input }
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

        context "when swap" do
          let(:status_change){ status_upgrade_with_swap }
          specify{ expect(primary_output_taxon_concept.name_status).to eq('A') }
          specify{ expect(secondary_output_taxon_concept).to be_is_synonym }
          specify{ expect(secondary_output_taxon_concept.accepted_names).to include(primary_output_taxon_concept) }
        end
      end
      context "from trade name" do
        let(:output_species){ secondary_output_taxon_concept }
        let(:status_upgrade_with_input){
          create(:nomenclature_change_status_change,
            primary_output_attributes: {
              is_primary_output: true,
              taxon_concept_id: trade_name.id,
              new_name_status: 'A'
            },
            input_attributes: { taxon_concept_id: input_species.id },
            status: NomenclatureChange::StatusChange::RECEIVE_OR_SWAP
          ).reload
        }
        let(:status_change){ status_upgrade_with_input }
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

        context "when swap" do
          let(:status_upgrade_with_swap){
            create(:nomenclature_change_status_change,
              primary_output_attributes: {
                is_primary_output: true,
                taxon_concept_id: trade_name.id,
                new_name_status: 'A'
              },
              input_attributes: { taxon_concept_id: input_species.id },
              secondary_output_attributes: {
                is_primary_output: false,
                taxon_concept_id: input_species.id,
                new_name_status: 'T'
              },
              status: NomenclatureChange::StatusChange::RECEIVE_OR_SWAP
            ).reload
          }
          let(:status_change){ status_upgrade_with_swap }
          specify{ expect(primary_output_taxon_concept.name_status).to eq('A') }
          specify{ expect(secondary_output_taxon_concept).to be_is_trade_name }
          specify{ expect(primary_output_taxon_concept.accepted_names_for_trade_name).to be_empty }
          specify{ expect(secondary_output_taxon_concept.accepted_names_for_trade_name).to include(primary_output_taxon_concept) }
        end
      end
    end
  end
end