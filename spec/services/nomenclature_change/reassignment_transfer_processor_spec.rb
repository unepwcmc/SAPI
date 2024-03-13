require 'spec_helper'

describe NomenclatureChange::ReassignmentTransferProcessor do
  include_context 'split_definitions'
  describe :run do
    context "input reassignments" do
      let(:split) { split_with_input_and_output }
      let(:input) { split.input }
      let(:output) { split.outputs.first }
      let(:processor) {
        NomenclatureChange::ReassignmentTransferProcessor.new(input, output)
      }
      context "when children" do
        include_context 'parent_reassignments_processor_examples'
      end
      context "when names" do
        include_context 'name_reassignments_processor_examples'
        specify { expect(input_species.synonyms).to be_empty }
      end
      context "when distribution" do
        include_context 'distribution_reassignments_processor_examples'
        specify { expect(input_species.distributions).to be_empty }
      end
      context "when legislation" do
        include_context 'legislation_reassignments_processor_examples'
        specify { expect(input_species.listing_changes).to be_empty }
        specify { expect(input_species.quotas).to be_empty }
        specify { expect(input_species.cites_suspensions).to be_empty }
      end
      context "when common names" do
        include_context 'common_name_reassignments_processor_examples'
        specify { expect(input_species.common_names).to be_empty }
      end
      context "when references" do
        include_context 'reference_reassignments_processor_examples'
        specify { expect(input_species.taxon_concept_references).to be_empty }
      end
      context "when document citations" do
        include_context 'document_reassignments_processor_examples'
        pending { expect(input_species.document_citation_taxon_concepts).to be_empty }
      end
      context "when shipments" do
        include_context 'shipment_reassignments_processor_examples'
      end
    end

    context "output reassignments" do
      let(:split) { split_with_input_and_outputs_name_change }
      let(:output) { split.outputs.last }
      let(:old_output_subspecies) { output.taxon_concept }
      let(:new_output_species) { output.new_taxon_concept }
      let(:output_processor) {
        NomenclatureChange::OutputTaxonConceptProcessor.new(output)
      }
      let(:processor) {
        NomenclatureChange::ReassignmentTransferProcessor.new(output, output)
      }
      context "when names" do
        include_context 'output_name_reassignments_processor_examples'
      end
      context "when distribution" do
        include_context 'output_distribution_reassignments_processor_examples'
      end
      context "when legislation" do
        include_context 'output_legislation_reassignments_processor_examples'
      end
      context "when common names" do
        include_context 'output_common_name_reassignments_processor_examples'
      end
      context "when references" do
        include_context 'output_reference_reassignments_processor_examples'
      end
      context "when document citations" do
        include_context 'output_document_reassignments_processor_examples'
      end
      context "when shipments" do
        include_context 'output_shipment_reassignments_processor_examples'
      end
    end
  end
end
