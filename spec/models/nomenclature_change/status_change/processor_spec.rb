require 'spec_helper'

describe NomenclatureChange::StatusChange::Processor do
  include_context 'status_change_definitions'

  before(:each){ synonym_relationship_type }
  let(:processor){ NomenclatureChange::StatusChange::Processor.new(status_change) }
  describe :run do
    context "when downgrade" do
      let(:status_change){ status_downgrade_with_input_and_secondary_output }
      before(:each){ processor.run }
      specify { expect(status_change.primary_output.taxon_concept.name_status).to eq('S') }
      specify { expect(status_change.secondary_output.taxon_concept.name_status).to eq('A') }

      context "when swap" do
        let(:status_change){ status_downgrade_with_swap }
        specify { expect(status_change.primary_output.taxon_concept.name_status).to eq('S') }
        specify { expect(status_change.secondary_output.taxon_concept.name_status).to eq('A') }
      end
    end
    context "when upgrade" do
      let(:output_species){ status_change.secondary_output.taxon_concept }
      let(:status_change){ status_upgrade_with_input }
      before(:each){ processor.run }
      specify { expect(status_change.primary_output.taxon_concept.name_status).to eq('A') }

      context "when swap" do
        let(:status_change){ status_upgrade_with_swap }
        specify { expect(status_change.primary_output.taxon_concept.name_status).to eq('A') }
        specify { expect(status_change.secondary_output.taxon_concept.name_status).to eq('S') }
      end
    end
  end
end