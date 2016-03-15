require 'spec_helper'

describe NomenclatureChange::StatusToSynonym::Constructor do
  include_context 'status_change_definitions'

  let(:constructor){ NomenclatureChange::StatusToSynonym::Constructor.new(status_change) }
  let(:input_species){ create_cites_eu_species(name_status: 'N') }

  describe :build_input do
    let(:status_change){ n_to_s_with_primary_output }
    before(:each) do
      @old_input = status_change.input
      constructor.build_input
    end
    context "when previously no input in place" do
      specify{ expect(status_change.input).not_to be_nil }
    end
    context "when previously input in place" do
      let(:status_change){ n_to_s_with_input_and_secondary_output }
      specify{ expect(status_change.input).to eq(@old_input) }
    end
  end

  describe :build_output_notes do
    let(:primary_output){ status_change.primary_output }
    let(:secondary_output){ status_change.secondary_output }
    before(:each) do
      @old_primary_output_note = primary_output.internal_note
      @old_secondary_output_note = secondary_output.note_en
      constructor.build_output_notes
    end

    let(:status_change){ n_to_s_with_input_and_secondary_output }
    context "when previously no notes in place" do
      specify{ expect(primary_output.internal_note).not_to be_blank }
      specify{ expect(secondary_output.note_en).to be_blank }
    end
    context "when previously notes in place" do
      let(:primary_output){
        create(:nomenclature_change_input, nomenclature_change: status_change, internal_note: 'blah')
      }
      specify{ expect(primary_output.internal_note).to eq(@old_primary_output_note) }
    end
  end

end
