require 'spec_helper'

describe NomenclatureChange::ReassignmentProcessor do
  include_context 'split_definitions'
  describe :run do
    let(:split){ split_with_input_and_output }
    let(:input){ split.input }
    let(:output){ split.outputs.first }
    let(:processor){
      NomenclatureChange::ReassignmentProcessor.new(input, output)
    }

    context "when children" do
      include_context 'parent_reassignments_processor_examples'
    end
    context "when names" do
      include_context 'name_reassignments_processor_examples'
      specify{ expect(input_species.synonyms).to be_empty }
    end
    context "when distribution" do
      include_context 'distribution_reassignments_processor_examples'
      specify{ expect(input_species.distributions).to be_empty }
    end
    context "when listing changes" do
      include_context 'legislation_reassignments_processor_examples'
      specify{ expect(input_species.listing_changes).to be_empty }
    end
    context "when common names" do
      include_context 'common_name_reassignments_processor_examples'
      specify{ expect(input_species.common_names).to be_empty }
    end
    context "when references" do
      include_context 'reference_reassignments_processor_examples'
      specify{ expect(input_species.taxon_concept_references).to be_empty }
    end
  end
end