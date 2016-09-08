require 'spec_helper'

describe NomenclatureChange::OutputTaxonConceptProcessor do
  include_context 'split_definitions'

  before(:each) { synonym_relationship_type }
  describe :run do
    let(:processor) {
      NomenclatureChange::OutputTaxonConceptProcessor.new(output)
    }
    before(:each) do
      processor.run
    end
    context "when output is existing taxon" do
      let(:output) { split_with_input_and_output_existing_taxon.outputs.last }
      specify { expect(output.new_taxon_concept).to be_nil }
    end
    context "when output is new taxon" do
      let(:output) { split_with_input_and_output_new_taxon.outputs.last }
      specify { expect(output.new_taxon_concept.full_name).to eq('Errorus fatalus') }
    end
    context "when output is existing taxon with new status" do
      let(:output) { split_with_input_and_outputs_status_change.outputs.last }
      specify { expect(output.new_taxon_concept).to be_nil }
      specify { expect(output.taxon_concept.name_status).to eq('A') }
    end
    context "when output is existing taxon with new name" do
      let(:output) { split_with_input_and_outputs_name_change.outputs.last }
      specify { expect(output.taxon_concept.full_name).to eq('Errorus fatalus fatalus') }
      specify { expect(output.new_taxon_concept.name_status).to eq('A') }
      specify { expect(output.new_taxon_concept.full_name).to eq('Errorus lolcatus') }
    end
  end
end
