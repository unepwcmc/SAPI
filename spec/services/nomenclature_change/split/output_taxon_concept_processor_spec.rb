require 'spec_helper'

describe NomenclatureChange::OutputTaxonConceptProcessor do
  include_context 'split_definitions'

  before(:each) { synonym_relationship_type }
  describe :run do
    let(:processor) do
      NomenclatureChange::OutputTaxonConceptProcessor.new(output)
    end

    context 'when output is existing taxon' do
      let(:output) { split_with_input_and_output_existing_taxon.outputs.last }
      before(:each) { processor.run }
      specify { expect(output.new_taxon_concept).to be_nil }
    end
    context 'when output is new taxon' do
      let(:output) { split_with_input_and_output_new_taxon.outputs.last }
      before(:each) { processor.run }
      specify { expect(output.new_taxon_concept.full_name).to eq('Errorus fatalus') }
    end
    context 'when output is existing taxon with new status' do
      let(:output) { split_with_input_and_outputs_status_change.outputs.last }
      before(:each) { processor.run }
      specify { expect(output.new_taxon_concept).to be_nil }
      specify { expect(output.taxon_concept.name_status).to eq('A') }
    end
    context 'when output is existing taxon with new name' do
      let(:output) { split_with_input_and_outputs_name_change.outputs.last }
      before(:each) { processor.run }
      specify { expect(output.taxon_concept.full_name).to eq('Errorus fatalus fatalus') }
      specify { expect(output.new_taxon_concept.name_status).to eq('A') }
      specify { expect(output.new_taxon_concept.full_name).to eq('Errorus lolcatus') }
    end
    context 'when output does not resolve to a destination taxon concept' do
      let(:output) { build(:nomenclature_change_output, taxon_concept: nil) }

      specify do
        expect { processor.run }.to raise_error(
          NomenclatureChange::Processor::ProcessingError,
          /No destination taxon concept available/
        )
      end
    end
    context 'when saving the destination taxon concept fails' do
      let(:output) { split_with_input_and_output_new_taxon.outputs.last }
      let(:taxon_concept) { output.tmp_taxon_concept }

      before(:each) do
        allow(output).to receive(:tmp_taxon_concept).and_return(taxon_concept)
        allow(taxon_concept).to receive(:save).and_return(false)
        allow(taxon_concept.errors).to receive(:full_messages).and_return(
          [ 'Scientific name has already been taken' ]
        )
      end

      specify do
        expect { processor.run }.to raise_error(
          NomenclatureChange::Processor::ProcessingError,
          /Could not save destination taxon concept: Scientific name has already been taken/
        )
      end
    end
  end
end
