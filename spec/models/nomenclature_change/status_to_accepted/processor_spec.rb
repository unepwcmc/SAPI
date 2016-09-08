require 'spec_helper'

describe NomenclatureChange::StatusToAccepted::Processor do
  include_context 'status_change_definitions'

  let(:accepted_name) { create_cites_eu_species }

  let(:trade_name) {
    tc = create_cites_eu_species(
      name_status: 'T',
      taxon_name: create(:taxon_name, scientific_name: 'Lolcatus nonsensus')
    )
    create(:taxon_relationship,
      taxon_concept: accepted_name,
      other_taxon_concept: tc,
      taxon_relationship_type: trade_name_relationship_type
    )
    tc
  }
  let(:trade_name_genus) {
    create_cites_eu_genus(
      taxon_name: create(:taxon_name, scientific_name: 'Lolcatus')
    )
  }
  let(:synonym) {
    tc = create_cites_eu_species(
      name_status: 'S',
      taxon_name: create(:taxon_name, scientific_name: 'Foobarus ridiculus')
    )
    create(:taxon_relationship,
      taxon_concept: accepted_name,
      other_taxon_concept: tc,
      taxon_relationship_type: synonym_relationship_type
    )
    tc
  }
  let(:synonym_genus) {
    create_cites_eu_genus(
      taxon_name: create(:taxon_name, scientific_name: 'Foobarus')
    )
  }
  before(:each) { synonym_relationship_type }
  let(:processor) { NomenclatureChange::StatusToAccepted::Processor.new(status_change) }
  let(:primary_output_taxon_concept) { status_change.primary_output.taxon_concept }
  let(:secondary_output_taxon_concept) { status_change.secondary_output.taxon_concept }

  describe :run do
    context "from trade name" do
      let(:output_species) { secondary_output_taxon_concept }
      let(:status_change) { t_to_a_with_input }
      before(:each) {
        @shipment = create(:shipment,
          taxon_concept: accepted_name,
          reported_taxon_concept: primary_output_taxon_concept
        )
        processor.run
      }
      specify { expect(primary_output_taxon_concept.name_status).to eq('A') }
      specify { expect(primary_output_taxon_concept.accepted_names_for_trade_name).to be_empty }
      specify { expect(primary_output_taxon_concept.shipments).to include(@shipment) }
      specify { expect(primary_output_taxon_concept.reported_shipments).to include(@shipment) }
      specify { expect(accepted_name.shipments).to be_empty }
    end
  end

end
