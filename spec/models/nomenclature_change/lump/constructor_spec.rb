require 'spec_helper'

describe NomenclatureChange::Lump::Constructor do
  include_context 'lump_definitions'

  let(:constructor) { NomenclatureChange::Lump::Constructor.new(lump) }
  context :inputs do
    describe :build_inputs do
      let(:lump) { create(:nomenclature_change_lump) }
      before(:each) do
        @old_inputs = lump.inputs
        constructor.build_inputs
      end
      context "when previously no inputs in place" do
        specify { expect(lump.inputs.size).not_to eq(0) }
      end
      context "when previously inputs in place" do
        let(:lump) { lump_with_inputs }
        specify { expect(lump.inputs).to eq(@old_inputs) }
      end
    end
  end
  context :outputs do
    describe :build_output do
      let(:lump) { lump_with_inputs }
      before(:each) do
        @old_output = lump.output
        constructor.build_output
      end
      context "when previously no output in place" do
        specify { expect(lump.output).not_to be_nil }
      end
      context "when previously output in place" do
        let(:lump) { lump_with_inputs_and_output }
        specify { expect(lump.output).to eq(@old_output) }
      end
    end
  end
  context :reassignments do
    let(:lump) { lump_with_inputs_and_output }
    let(:nc) { lump }
    let(:input) { nc.inputs[0] }
    describe :build_input_and_output_notes do
      let(:output) { lump.output }
      before(:each) do
        @old_input_note = input.note_en
        @old_output_note = output.note_en
        constructor.build_input_and_output_notes
      end
      context "when previously no notes in place" do
        let(:lump) {
          create(:nomenclature_change_lump,
            inputs_attributes: {
              0 => { taxon_concept_id: input_species1.id },
              1 => { taxon_concept_id: input_species2.id }
            },
            output_attributes: { taxon_concept_id: output_species.id }
          )
        }
        specify { expect(input.note_en).not_to be_blank }
        specify { expect(output.note_en).not_to be_blank }
        context "when output = input" do
          let(:lump) {
            create(:nomenclature_change_lump,
              inputs_attributes: {
                0 => { taxon_concept_id: input_species1.id },
                1 => { taxon_concept_id: input_species2.id }
              },
              output_attributes: { taxon_concept_id: input_species1.id }
            )
          }
          specify { expect(input.note_en).to be_blank }
        end
      end
      context "when previously notes in place" do
        let(:input) {
          create(:nomenclature_change_input, nomenclature_change: lump, note_en: 'blah')
        }
        let(:output) {
          create(:nomenclature_change_output, nomenclature_change: lump, note_en: 'blah')
        }
        specify { expect(input.note_en).to eq(@old_input_note) }
        specify { expect(output.note_en).to eq(@old_output_note) }
      end
    end
    describe :build_parent_reassignments do
      before(:each) do
        @old_reassignments = input.parent_reassignments
        constructor.build_parent_reassignments
      end
      include_context 'parent_reassignments_constructor_examples'

      context "when output = input" do
        let(:input_species) {
          s = create_cites_eu_species
          2.times { create_cites_eu_subspecies(parent: s) }
          s
        }
        let(:lump_with_inputs_and_output) { lump_with_inputs_and_same_output }
        let(:input) { lump.inputs_intersect_outputs.first }
        let(:default_output) { lump.output }
        specify {
          reassignment_targets = input.parent_reassignments.map(&:reassignment_target)
          expect(reassignment_targets.map(&:output).uniq).to(eq([default_output]))
        }
      end

      context "when previously reassignments in place" do
        let(:input) {
          i = create(:nomenclature_change_input, nomenclature_change: lump, taxon_concept: input_species)
          create(:nomenclature_change_parent_reassignment, input: i)
          i
        }
        specify { expect(input.parent_reassignments).to eq(@old_reassignments) }
      end
    end
    describe :build_name_reassignments do
      before(:each) do
        @old_reassignments = input.name_reassignments
        constructor.build_name_reassignments
      end
      include_context 'name_reassignments_constructor_examples'

      context "when output = input" do
        let(:input_species) {
          s = create_cites_eu_species
          2.times do
            create(:taxon_relationship,
              taxon_concept: s,
              other_taxon_concept: create_cites_eu_species(name_status: 'S'),
              taxon_relationship_type: synonym_relationship_type
            )
          end
          s
        }
        let(:lump_with_inputs_and_output) { lump_with_inputs_and_same_output }
        let(:input) { lump.inputs_intersect_outputs.first }
        let(:default_output) { lump.output }
        specify {
          reassignment_targets = input.name_reassignments.map do |reassignment|
            reassignment.reassignment_targets
          end.flatten
          expect(reassignment_targets.map(&:output).uniq).to eq([default_output])
        }
      end

    end
    describe :build_distribution_reassignments do
      before(:each) do
        @old_reassignments = input.distribution_reassignments
        constructor.build_distribution_reassignments
      end
      include_context 'distribution_reassignments_constructor_examples'
    end
    describe :build_document_reassignments do
      before(:each) do
        constructor.build_distribution_reassignments
        constructor.build_document_reassignments
      end
      include_context 'document_reassignments_constructor_examples'
    end
    describe :build_legislation_reassignments do
      before(:each) do
        @old_reassignments = input.legislation_reassignments
        constructor.build_legislation_reassignments
      end
      include_context 'legislation_reassignments_constructor_examples'
    end
    describe :build_common_names_reassignments do
      before(:each) do
        @old_reassignments = input.reassignments
        constructor.build_common_names_reassignments
      end
      include_context 'common_name_reassignments_constructor_examples'
    end
    describe :build_references_reassignments do
      before(:each) do
        @old_reassignments = input.reassignments
        constructor.build_references_reassignments
      end
      include_context 'reference_reassignments_constructor_examples'
    end
  end
end
