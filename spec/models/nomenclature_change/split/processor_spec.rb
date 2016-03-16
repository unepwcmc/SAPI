require 'spec_helper'

describe NomenclatureChange::Split::Processor do
  include_context 'split_definitions'

  before(:each){
    synonym_relationship_type
    @shipment = create(:shipment,
      taxon_concept: input_species,
      reported_taxon_concept: input_species
    )
  }
  let(:processor){ NomenclatureChange::Split::Processor.new(split) }
  describe :run do
    context "when outputs are existing taxa" do
      let!(:split){ split_with_input_and_output_existing_taxon }
      specify { expect{ processor.run }.not_to change(TaxonConcept, :count) }
      specify { expect{ processor.run }.not_to change(output_species1, :full_name) }
      specify { expect{ processor.run }.not_to change(output_species2, :full_name) }
      context "relationships and trade" do
        before(:each){ processor.run }
        specify{ expect(input_species.reload).to be_is_synonym }
        specify{ expect(input_species.accepted_names).to include(output_species1) }
        specify{ expect(input_species.shipments).to be_empty }
        specify{ expect(input_species.reported_shipments).to include(@shipment) }
        specify{ expect(output_species1.shipments).to include(@shipment) }
      end
    end
    context "when output is new taxon" do
      let!(:split){ split_with_input_and_output_new_taxon }
      specify { expect{ processor.run }.to change(TaxonConcept, :count).by(1) }
      context "relationships and trade" do
        before(:each){ processor.run }
        specify{ expect(input_species.reload).to be_is_synonym }
        specify{ expect(input_species.accepted_names).to include(split.outputs.last.new_taxon_concept) }
        specify{ expect(input_species.shipments).to be_empty }
        specify{ expect(input_species.reported_shipments).to include(@shipment) }
        specify{ expect(output_species1.shipments).to include(@shipment) }
      end
    end
    context "when output is existing taxon with new status" do
      let(:output_species2){
        create_cites_eu_species(
          name_status: 'S',
          taxon_name: create(:taxon_name, scientific_name: 'Notio mirabilis')
        )
      }
      let(:genus2){
        create_cites_eu_genus(
          taxon_name: create(:taxon_name, scientific_name: 'Notio')
        )
      }
      let!(:split){ split_with_input_and_outputs_status_change }
      specify { expect{ processor.run }.not_to change(TaxonConcept, :count) }
      specify { expect{ processor.run }.not_to change(output_species1, :full_name) }
      specify { expect{ processor.run }.not_to change(output_species2, :full_name) }
      context "relationships and trade" do
        before(:each){ processor.run }
        specify{ expect(input_species.reload).to be_is_synonym }
        specify{ expect(input_species.accepted_names).to include(output_species1) }
        specify{ expect(output_species1.shipments).to include(@shipment) }
      end
    end
    context "when output is existing taxon with new name" do
      let(:output_species2){ create_cites_eu_subspecies }
      let!(:split){ split_with_input_and_outputs_name_change }
      specify { expect{ processor.run }.to change(TaxonConcept, :count).by(1) }
      specify { expect{ processor.run }.not_to change(output_species1, :full_name) }
      specify { expect{ processor.run }.not_to change(output_species2, :full_name) }
      context "relationships and trade" do
        before(:each){ processor.run }
        specify{ expect(input_species.reload).to be_is_synonym }
        specify{ expect(input_species.reload.parent_id).to be_nil }
        specify{ expect(input_species.accepted_names).to include(split.outputs.last.new_taxon_concept) }
        specify{ expect(output_species1.shipments).to include(@shipment) }
      end
    end
  end
  describe :summary do
    let(:split){ split_with_input_and_output_existing_taxon }
    specify { expect(processor.summary).to be_kind_of(Array) }
  end
end