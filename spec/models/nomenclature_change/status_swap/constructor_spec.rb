require 'spec_helper'

describe NomenclatureChange::StatusSwap::Constructor do
  include_context 'status_change_definitions'

  let(:constructor){ NomenclatureChange::StatusSwap::Constructor.new(status_change) }
  describe :build_primary_output do
    let(:status_change){ create(:nomenclature_change_status_swap) }
    before(:each) do
      @old_output = status_change.primary_output
      constructor.build_primary_output
    end
    context "when previously no primary output in place" do
      specify{ expect(status_change.primary_output).not_to be_nil }
    end
    context "when previously primary output in place" do
      let(:status_change){ a_to_s_with_swap }
      specify{ expect(status_change.primary_output).to eq(@old_output) }
    end
  end

  describe :build_secondary_output do
    context :downgrade do
      let(:status_change){ a_to_s_with_swap_with_primary_output }
      before(:each) do
        @old_output = status_change.secondary_output
        constructor.build_secondary_output
      end
      context "when previously no secondary output in place" do
        specify{ expect(status_change.secondary_output).not_to be_nil }
      end
      context "when previously secondary output in place" do
        let(:status_change){ a_to_s_with_swap }
        specify{ expect(status_change.secondary_output).to eq(@old_output) }
      end
    end
  end

  describe :build_output_notes do
    let(:new_accepted_name){ status_change.new_accepted_name }
    before(:each) do
      @old_new_accepted_name_note = new_accepted_name.note_en
      constructor.build_output_notes
    end
    let(:status_change){ a_to_s_with_swap }
    context "when previously no notes in place" do
      specify{ expect(new_accepted_name.internal_note).to be_blank }
      specify{ expect(new_accepted_name.note_en).not_to be_blank }
    end
    context "when previously notes in place" do
      let(:new_accepted_name){
        create(:nomenclature_change_output, nomenclature_change: status_change, note_en: 'blah')
      }
      specify{ expect(new_accepted_name.note_en).to eq(@old_new_accepted_name_note) }
    end
  end

end
