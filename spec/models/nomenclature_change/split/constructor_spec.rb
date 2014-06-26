require 'spec_helper'

describe NomenclatureChange::Split::Constructor do
  include_context 'split_definitions'

  let(:constructor){ NomenclatureChange::Split::Constructor.new(split) }
  context :inputs do
    describe :build_input do
      let(:split){ create(:nomenclature_change_split) }
      before(:each){ @old_input = split.input; constructor.build_input }
      context "when previously no input in place" do
        specify{ expect(split.input).not_to be_nil }
      end
      context "when previously input in place" do
        let(:split){ split_with_input }
        specify{ expect(split.input).to eq(@old_input) }
      end
    end
  end
  context :outputs do
    describe :build_outputs do
      let(:split){ split_with_input }
      before(:each){ @old_outputs = split.outputs; constructor.build_outputs }
      context "when previously no outputs in place" do
        specify{ expect(split.outputs.size).not_to eq(0) }
      end
      context "when previously output in place" do
        let(:split){ split_with_input_and_output }
        specify{ expect(split.outputs).to eq(@old_outputs) }
      end
    end
  end
  context :reassignments do
    let(:split){ split_with_input_and_output }
    let(:nc){ split }
    let(:nc_with_input_and_output) { split_with_input_and_output }
    let(:nc_with_input_and_same_output) { split_with_input_and_same_output }
    let(:input){ nc.input }
    describe :build_input_and_output_notes do
      let(:output){ split.outputs[0] }
      before(:each) do
        @old_input_note = input.note
        @old_output_note = output.note
        constructor.build_input_and_output_notes
      end
      context "when previously no notes in place" do
        let(:split){
          s = create(:nomenclature_change_split)
          create(:nomenclature_change_input, nomenclature_change: s, note: nil)
          create(:nomenclature_change_output, nomenclature_change: s, note: nil)
          s
        }
        specify{ expect(input.note).not_to be_blank }
        specify{ expect(output.note).not_to be_blank }
        context "when output = input" do
          let(:split){
            s = create(:nomenclature_change_split)
            create(:nomenclature_change_input, nomenclature_change: s, taxon_concept: input_species, note: nil)
            create(:nomenclature_change_output, nomenclature_change: s, taxon_concept: input_species, note:nil)
            s
          }
          specify{ expect(output.note).to be_blank }
        end
      end
      context "when previously notes in place" do
        let(:input){
          create(:nomenclature_change_input, nomenclature_change: split, note: 'blah')
        }
        let(:output){
          create(:nomenclature_change_output, nomenclature_change: split, note: 'blah')
        }
        specify{ expect(input.note).to eq(@old_input_note) }
        specify{ expect(output.note).to eq(@old_output_note) }
      end
    end
    describe :build_parent_reassignments do
      before(:each) do
        @old_reassignments = input.parent_reassignments
        constructor.build_parent_reassignments
      end
      include_context 'parent_reassignments_examples'

      context "when output = input" do
        let(:input_species){
          s = create_cites_eu_species
          2.times{ create_cites_eu_subspecies(parent: s) }
          s
        }
        let(:split_with_input_and_output){ split_with_input_and_same_output }
        let(:default_output){ split.outputs_intersect_inputs.first }
        specify{
          reassignment_targets = input.parent_reassignments.map(&:reassignment_target)
          expect(reassignment_targets.map(&:output).uniq).to(eq([default_output]))
        }
      end

      context "when previously reassignments in place" do
        let(:input){
          i = create(:nomenclature_change_input, nomenclature_change: split, taxon_concept: input_species)
          create(:nomenclature_change_parent_reassignment, input: i)
          i
        }
        specify{ expect(input.parent_reassignments).to eq(@old_reassignments) }
      end
    end
    describe :build_name_reassignments do
      before(:each) do
        @old_reassignments = input.name_reassignments
        constructor.build_name_reassignments
      end
      include_context 'name_reassignments_examples'

      context "when output = input" do
        let(:input_species){
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
        let(:split_with_input_and_output){ split_with_input_and_same_output }
        let(:default_output){ split.outputs_intersect_inputs.first }
        specify{
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
      include_context 'distribution_reassignments_examples'
    end
    describe :build_legislation_reassignments do
      before(:each) do
        @old_reassignments = input.legislation_reassignments
        constructor.build_legislation_reassignments
      end
      include_context 'legislation_reassignments_examples'
    end
    describe :build_common_names_reassignments do
      before(:each) do
        @old_reassignments = input.reassignments
        constructor.build_common_names_reassignments
      end
      include_context 'common_name_reassignments_examples'
    end
    describe :build_references_reassignments do
      before(:each) do
        @old_reassignments = input.reassignments
        constructor.build_references_reassignments
      end
      include_context 'reference_reassignments_examples'
    end
  end
end
