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
      let(:input_genus1){ create_cites_eu_genus }
      let(:input_species1){ create_cites_eu_species(parent: input_genus1) }
      let(:output_species2){ create_cites_eu_subspecies }
      let!(:lump){ lump_with_inputs_and_output_name_change }
      specify { expect{ processor.run }.to change(TaxonConcept, :count).by(1) }
      specify { expect{ processor.run }.not_to change(output_species, :full_name) }
      context "relationships and trade" do
        before(:each){ processor.run }
        specify{ expect(input_species1.reload).to be_is_synonym }
        specify{ expect(input_species1.reload.parent).to eq(input_genus1) }
        specify{ expect(input_species1.accepted_names).to include(lump.output.new_taxon_concept) }
        specify{ expect(lump.output.new_taxon_concept.shipments).to include(@shipment) }
      end
    end
    context "when input with children that change name" do
      let!(:input_species1_child){
        create_cites_eu_subspecies(parent: input_species1)
      }
      let!(:input_species1_child_listing){
        create_cites_I_addition(taxon_concept: input_species1_child)
      }
      let(:lump){
        create(:nomenclature_change_lump,
          inputs_attributes: {
            0 => {
              taxon_concept_id: input_species1.id,
              note_en: 'input EN note',
              internal_note: 'input internal note'
            },
            1 => { taxon_concept_id: input_species2.id }
          },
          output_attributes: {
            taxon_concept_id: output_species.id,
            note_en: 'output EN note',
            internal_note: 'output internal note'
          },
          status: NomenclatureChange::Lump::LEGISLATION
        )
      }
      let(:input){ lump.inputs.first }
      let(:output){ lump.output }
      let(:reassignment){
        create(:nomenclature_change_parent_reassignment,
          input: input,
          reassignable_id: input_species1_child.id
        )
      }
      let!(:reassignment_target){
        create(:nomenclature_change_reassignment_target,
          reassignment: reassignment,
          output: output
        )
      }
      let(:output_species_child){ output_species.children.first.reload }
      before(:each){ processor.run }
      specify do
        expect(input_species1.reload.nomenclature_note_en).to eq(' input EN note')
        expect(input_species1_child.reload.nomenclature_note_en).to eq(input_species1.nomenclature_note_en)
      end
      specify do
        expect(input_species1.nomenclature_comment.note).to eq(' input internal note')
        expect(input_species1_child.nomenclature_comment.note).to eq(input_species1.nomenclature_comment.note)
      end
      specify do
        expect(output_species.reload.nomenclature_note_en).to eq(' output EN note')
        expect(output_species_child.reload.nomenclature_note_en).to eq(output_species.nomenclature_note_en)
      end
      specify do
        expect(output_species.nomenclature_comment.note).to eq(' output internal note')
        expect(output_species_child.nomenclature_comment.note).to eq(output_species.nomenclature_comment.note)
      end
      specify do
        expect(output_species_child.listing_changes.count).to eq(1)
        expect(
          output_species_child.listing_changes.first.nomenclature_note_en
        ).to include(output_species.reload.nomenclature_note_en)
      end
    end
  end
  describe :summary do
    let(:lump){ lump_with_inputs_and_output_existing_taxon }
    specify { expect(processor.summary).to be_kind_of(Array) }
  end
end
