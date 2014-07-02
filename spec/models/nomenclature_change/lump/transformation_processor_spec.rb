require 'spec_helper'

describe NomenclatureChange::Lump::TransformationProcessor do
  include_context 'lump_definitions'

  describe :run do
    let(:processor){
      NomenclatureChange::Lump::TransformationProcessor.new(output)
    }
    before(:each) do
      processor.run
    end
    context "when output is existing taxon" do
      let(:output){ lump_with_input_and_output_existing_taxon.outputs.last }
      specify{ expect(output.new_taxon_concept).to be_nil }
    end
    context "when output is new taxon" do
      let(:output){ lump_with_input_and_output_new_taxon.outputs.last }
      specify{ expect(output.new_taxon_concept.full_name).to eq('Errorus fatalus') }
    end
    context "when output is existing taxon with new status" do
      let(:output){ lump_with_input_and_outputs_status_change.outputs.last }
      specify{ expect(output.new_taxon_concept).to be_nil }
      specify{ expect(output.taxon_concept.name_status).to eq('A') }
    end
    context "when output is existing taxon with new name" do
      let(:output){ lump_with_input_and_outputs_name_change.outputs.last }
      specify{ expect(output.taxon_concept.full_name).to eq('Errorus fatalus fatalus') }
      pending{ expect(output.taxon_concept.reload.name_status).to eq('S') }
      specify{ expect(output.new_taxon_concept.name_status).to eq('A') }
      specify{ expect(output.new_taxon_concept.full_name).to eq('Errorus lolcatus') }
    end
  end
end
