require 'spec_helper'

describe NomenclatureChange::Split::Constructor do
  include_context 'split_definitions'

  let(:constructor) { NomenclatureChange::Split::Constructor.new(split) }
  context :inputs do
    describe :build_input do
      let(:split) { create(:nomenclature_change_split) }
      before(:each) do
        @old_input = split.input
        constructor.build_input
      end
      context "when previously no input in place" do
        specify { expect(split.input).not_to be_nil }
      end
      context "when previously input in place" do
        let(:split) { split_with_input }
        specify { expect(split.input).to eq(@old_input) }
      end
    end
  end
  context :outputs do
    describe :build_outputs do
      let(:split) { split_with_input }
      before(:each) do
        @old_outputs = split.outputs
        constructor.build_outputs
      end
      context "when previously no outputs in place" do
        specify { expect(split.outputs.size).not_to eq(0) }
      end
      context "when previously output in place" do
        let(:split) { split_with_input_and_output }
        specify { expect(split.outputs).to eq(@old_outputs) }
      end
    end
  end
  context :reassignments do
    let(:split) { split_with_input_and_output }
    let(:nc) { split }
    let(:input) { nc.input }
    describe :build_input_and_output_notes do
      let(:output) { split.outputs[0] }
      before(:each) do
        @old_input_note = input.note_en
        @old_output_note = output.note_en
        constructor.build_input_and_output_notes
      end
      context "when previously no notes in place" do
        let(:split) {
          s = create(:nomenclature_change_split)
          create(:nomenclature_change_input, nomenclature_change: s)
          create(:nomenclature_change_output, nomenclature_change: s)
          s
        }
        specify { expect(input.note_en).not_to be_blank }
        specify { expect(output.note_en).not_to be_blank }
        context "when output = input" do
          let(:split) {
            s = create(:nomenclature_change_split)
            create(:nomenclature_change_input, nomenclature_change: s, taxon_concept: input_species)
            create(:nomenclature_change_output, nomenclature_change: s, taxon_concept: input_species)
            s
          }
          specify { expect(output.note_en).to be_blank }
        end
      end
      context "when previously notes in place" do
        let(:input) {
          create(:nomenclature_change_input, nomenclature_change: split, note_en: 'blah')
        }
        let(:output) {
          create(:nomenclature_change_output, nomenclature_change: split, note_en: 'blah')
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
        let(:split_with_input_and_output) { split_with_input_and_same_output }
        let(:default_output) { split.outputs_intersect_inputs.first }
        specify {
          reassignment_targets = input.parent_reassignments.map(&:reassignment_target)
          expect(reassignment_targets.map(&:output).uniq).to(eq([default_output]))
        }
      end

      context "when previously reassignments in place" do
        let(:input) {
          i = create(:nomenclature_change_input, nomenclature_change: split, taxon_concept: input_species)
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
        let(:split_with_input_and_output) { split_with_input_and_same_output }
        let(:default_output) { split.outputs_intersect_inputs.first }
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
    describe :build_documents_reassignments do
      before(:each) do
        constructor.build_distribution_reassignments
        constructor.build_document_reassignments
      end
      include_context 'document_reassignments_constructor_examples'

      context "when geo_entity citations mismatch distribution" do
        let(:geo_entity){ create(:geo_entity) }
        let(:input_species) {
          s = create_cites_eu_species
          dc = create(:document_citation)
          create(
            :document_citation_taxon_concept,
            taxon_concept: s,
            document_citation: dc
          )
          create(
            :document_citation_geo_entity,
            geo_entity: geo_entity,
            document_citation: dc
          )
          create(
            :distribution,
            taxon_concept: s,
            geo_entity: geo_entity
          )
          s
        }
        let(:default_output) { split.outputs.first }
        let(:non_default_output){ split.outputs.where('id != ?', default_output.id).first }

        specify {

          distribution_reassignment = split.input.distribution_reassignments.first
          reassignment_targets = distribution_reassignment.reassignment_targets
          non_default_target = reassignment_targets.where(
            nomenclature_change_output_id: non_default_output.id
          ).first
          non_default_target.destroy
          distribution_reassignment.reassignment_targets.reload


          # split.input.distribution_reassignments.first.
          #   update_attributes(output_ids: [split.outputs.first.id])
          constructor.build_document_reassignments
          expect(split.input.document_citation_reassignments.first.
            output_ids).not_to include(non_default_output.id)
        }
      end
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
