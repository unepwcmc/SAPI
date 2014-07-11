require 'spec_helper'

describe NomenclatureChange::ReassignmentCopyProcessor do
  include_context 'split_definitions'
  describe :run do
    let(:split){ split_with_input_and_same_output }
    let(:input){ split.input }
    let(:output){ split.outputs.first }
    let(:processor){
      NomenclatureChange::ReassignmentCopyProcessor.new(input, output)
    }

    context "when children" do
      include_context 'parent_reassignments_processor_examples'
    end
    context "when names" do
      include_context 'name_reassignments_processor_examples'
      specify{ expect(input_species.synonyms).to include(input_species_synonym) }
    end
    context "when distribution" do
      include_context 'distribution_reassignments_processor_examples'
      specify{ expect(input_species.distributions.count).to eq(2) }
    end
    context "when listing changes" do
      include_context 'legislation_reassignments_processor_examples'
      specify{ expect(input_species.listing_changes.count).to eq(2) }
    end
    context "when common names" do
      include_context 'common_name_reassignments_processor_examples'
      specify{ expect(input_species.common_names.count).to eq(1) }
    end
  end
end