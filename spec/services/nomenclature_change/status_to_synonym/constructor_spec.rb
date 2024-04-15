require 'spec_helper'

describe NomenclatureChange::StatusToSynonym::Constructor do
  include_context 'status_change_definitions'

  let(:constructor) { NomenclatureChange::StatusToSynonym::Constructor.new(status_change) }
  let(:input_species) { create_cites_eu_species(name_status: 'N') }

  describe :build_input do
    let(:status_change) { n_to_s_with_primary_output }
    before(:each) do
      @old_input = status_change.input
      constructor.build_input
    end
    context "when previously no input in place" do
      specify { expect(status_change.input).not_to be_nil }
    end
    context "when previously input in place" do
      let(:status_change) { n_to_s_with_input_and_secondary_output }
      specify { expect(status_change.input).to eq(@old_input) }
    end
  end

end
