require 'spec_helper'

describe NomenclatureChange::StatusChange::Constructor do
  include_context 'status_change_definitions'

  let(:constructor){ NomenclatureChange::StatusChange::Constructor.new(status_change) }
  describe :build_primary_output do
    let(:status_change){ create(:nomenclature_change_status_change) }
    before(:each) do
      @old_output = status_change.primary_output
      constructor.build_primary_output
    end
    context "when previously no primary output in place" do
      specify{ expect(status_change.primary_output).not_to be_nil }
    end
    context "when previously primary output in place" do
      let(:status_change){ status_downgrade_with_primary_output }
      specify{ expect(status_change.primary_output).to eq(@old_output) }
    end
  end


  describe :build_secondary_output do
    context :downgrade do
      let(:status_change){ status_downgrade_with_primary_output }
      before(:each) do
        @old_output = status_change.secondary_output
        constructor.build_secondary_output
      end
      context "when previously no secondary output in place" do
        specify{ expect(status_change.secondary_output).not_to be_nil }
      end
      context "when previously secondary output in place" do
        let(:status_change){ status_downgrade_with_input_and_secondary_output }
        specify{ expect(status_change.secondary_output).to eq(@old_output) }
      end
    end
  end
  describe :build_input do
    context :downgrade do
      let(:status_change){ status_downgrade_with_primary_output }
      before(:each) do
        @old_input = status_change.input
        constructor.build_input
      end
      context "when previously no input in place" do
        specify{ expect(status_change.input).not_to be_nil }
      end
      context "when previously input in place" do
        let(:status_change){ status_downgrade_with_input_and_secondary_output }
        specify{ expect(status_change.input).to eq(@old_input) }
      end
    end
    context :upgrade do
      let(:status_change){ status_upgrade_with_primary_output }
      before(:each) do
        @old_input = status_change.input
        constructor.build_input
      end
      context "when previously no input in place" do
        specify{ expect(status_change.input).not_to be_nil }
      end
      context "when previously input in place" do
        let(:status_change){ status_upgrade_with_input }
        specify{ expect(status_change.input).to eq(@old_input) }
      end
    end
  end
  context "reassignments" do
    let(:nc_with_input_and_output){ status_upgrade_with_input }
    let(:nc_with_input_and_same_output){ status_downgrade_with_input_and_secondary_output }
    let(:nc){ nc_with_input_and_output }
    let(:status_change){ nc }
    let(:input){ nc.input }
    describe :build_parent_reassignments do
      before(:each) do
        @old_reassignments = input.parent_reassignments
        constructor.build_parent_reassignments
      end
      include_context 'parent_reassignments_examples'
    end
    describe :build_name_reassignments do
      before(:each) do
        @old_reassignments = input.name_reassignments
        constructor.build_name_reassignments
      end
      include_context 'name_reassignments_examples'
    end
    describe :build_distribution_reassignments do
      before(:each) do
        @old_reassignments = input.distribution_reassignments
        constructor.build_distribution_reassignments
      end
      include_context 'distribution_reassignments_examples'
    end
    describe :build_legislation_reassignments do
      before(:each) do
        @old_reassignments = input.legislation_reassignments
        constructor.build_legislation_reassignments
      end
      include_context 'legislation_reassignments_examples'
    end
    describe :build_common_names_reassignments do
      before(:each) do
        @old_reassignments = input.reassignments
        constructor.build_common_names_reassignments
      end
      include_context 'common_name_reassignments_examples'
    end
    describe :build_references_reassignments do
      before(:each) do
        @old_reassignments = input.reassignments
        constructor.build_references_reassignments
      end
      include_context 'reference_reassignments_examples'
    end
  end
  describe :build_output_notes do
    let(:primary_output){ status_change.primary_output }
    let(:secondary_output){ status_change.secondary_output }
    before(:each) do
      @old_primary_output_note = primary_output.note
      @old_secondary_output_note = secondary_output.note
      constructor.build_output_notes
    end
    context 'not swap' do
      let(:status_change){ status_downgrade_with_input_and_secondary_output }
      context "when previously no notes in place" do
        specify{ expect(primary_output.note).not_to be_blank }
        specify{ expect(secondary_output.note).to be_blank }
      end
      context "when previously notes in place" do
        let(:primary_output){
          create(:nomenclature_change_input, nomenclature_change: status_change, note: 'blah')
        }
        specify{ expect(primary_output.note).to eq(@old_primary_output_note) }
      end
    end
    context 'swap' do
      let(:status_change){ status_downgrade_with_swap }
      context "when previously no notes in place" do
        specify{ expect(primary_output.note).not_to be_blank }
        specify{ expect(secondary_output.note).not_to be_blank }
      end
      context "when previously notes in place" do
        let(:primary_output){
          create(:nomenclature_change_input, nomenclature_change: status_change, note: 'blah')
        }
        let(:secondary_output){
          create(:nomenclature_change_output, nomenclature_change: status_change, note: 'blah')
        }
        specify{ expect(primary_output.note).to eq(@old_primary_output_note) }
        specify{ expect(secondary_output.note).to eq(@old_secondary_output_note) }
      end
    end
  end
end
