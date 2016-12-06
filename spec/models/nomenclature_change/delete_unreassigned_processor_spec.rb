require 'spec_helper'

describe NomenclatureChange::DeleteUnreassignedProcessor do
  include_context 'split_definitions'

  before(:each) do
    processor.run
  end

  describe :run do
    let(:split) { split_with_input_with_reassignments }
    let(:input) { split.input }
    let(:processor) {
      NomenclatureChange::DeleteUnreassignedProcessor.new(input)
    }

    context "delete unreassigned" do
      specify { expect(input_species.distributions.count).to eq(1) }
      specify { expect(input_species.taxon_relationships.count).to eq(2) }
      specify { expect(input_species.document_citation_taxon_concepts.count).to eq(1) }
    end
  end

end
