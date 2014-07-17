require 'spec_helper'

describe NomenclatureChange::Lump::Processor do
  include_context 'lump_definitions'

  before(:each){
    synonym_relationship_type
    @shipment = create(:shipment,
      taxon_concept: input_species1,
      reported_taxon_concept: input_species1
    )
  }
  let(:processor){ NomenclatureChange::Lump::Processor.new(lump) }
  describe :run do
    context "when outputs are existing taxa" do
      let!(:lump){ lump_with_inputs_and_output_existing_taxon }
      specify { expect{ processor.run }.not_to change(TaxonConcept, :count) }
      specify { expect{ processor.run }.not_to change(output_species, :full_name) }
      context "relationships and trade" do
        before(:each){ processor.run }
        specify{ expect(input_species1.reload).to be_is_synonym }
        specify{ expect(input_species1.accepted_names).to include(output_species) }
        specify{ expect(input_species1.shipments).to be_empty }
        specify{ expect(input_species1.reported_shipments).to include(@shipment) }
        specify{ expect(output_species.shipments).to include(@shipment) }
      end
    end
    context "when output is new taxon" do
      let!(:lump){ lump_with_inputs_and_output_new_taxon }
      specify { expect{ processor.run }.to change(TaxonConcept, :count).by(1) }
      context "relationships and trade" do
        before(:each){ processor.run }
        specify{ expect(input_species1.reload).to be_is_synonym }
        specify{ expect(input_species1.accepted_names).to include(lump.output.new_taxon_concept) }
        specify{ expect(lump.output.new_taxon_concept.shipments).to include(@shipment) }
      end
    end
    context "when output is existing taxon with new status" do
      let(:output_species2){ create_cites_eu_species(:name_status => 'S') }
      let!(:lump){ lump_with_inputs_and_output_status_change }
      specify { expect{ processor.run }.not_to change(TaxonConcept, :count) }
      specify { expect{ processor.run }.not_to change(output_species, :full_name) }
      context "relationships and trade" do
        before(:each){ processor.run }
        specify{ expect(input_species1.reload).to be_is_synonym }
        specify{ expect(input_species1.accepted_names).to include(output_species) }
        specify{ expect(output_species.shipments).to include(@shipment) }
      end
    end
    context "when output is existing taxon with new name" do
      let(:output_species2){ create_cites_eu_subspecies }
      let!(:lump){ lump_with_inputs_and_output_name_change }
      specify { expect{ processor.run }.to change(TaxonConcept, :count).by(1) }
      specify { expect{ processor.run }.not_to change(output_species, :full_name) }
      context "relationships and trade" do
        before(:each){ processor.run }
        specify{ expect(input_species1.reload).to be_is_synonym }
        specify{ expect(input_species1.accepted_names).to include(lump.output.new_taxon_concept) }
        specify{ expect(lump.output.new_taxon_concept.shipments).to include(@shipment) }
      end
    end
  end
end
