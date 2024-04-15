require 'spec_helper'

describe NomenclatureChange::OutputTaxonConceptProcessor do
  include_context 'status_change_definitions'

  before(:each) { synonym_relationship_type }
  let(:input_species) { create_cites_eu_species(name_status: 'N') }

  describe :run do
    let(:processor) {
      NomenclatureChange::OutputTaxonConceptProcessor.new(primary_output)
    }
    before(:each) do
      processor.run
    end
    context "when output is existing taxon" do
      let(:primary_output) { n_to_s_with_input_and_secondary_output.primary_output }
      specify { expect(primary_output.new_taxon_concept).to be_nil }
    end
  end
end
