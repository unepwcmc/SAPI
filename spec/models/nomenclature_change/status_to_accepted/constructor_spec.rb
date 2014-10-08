require 'spec_helper'

describe NomenclatureChange::StatusToAccepted::Constructor do
  include_context 'status_change_definitions'

  let(:constructor){ NomenclatureChange::StatusToAccepted::Constructor.new(status_change) }

  describe :build_input do
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

  context "reassignments" do
    let(:nc){ status_upgrade_with_input }
    let(:status_change){ nc }
    let(:input){ nc.input }
    describe :build_parent_reassignments do
      before(:each) do
        @old_reassignments = input.parent_reassignments
        constructor.build_parent_reassignments
      end
      include_context 'parent_reassignments_constructor_examples'
    end
    describe :build_name_reassignments do
      before(:each) do
        @old_reassignments = input.name_reassignments
        constructor.build_name_reassignments
      end
      include_context 'name_reassignments_constructor_examples'
    end
    describe :build_distribution_reassignments do
      before(:each) do
        @old_reassignments = input.distribution_reassignments
        constructor.build_distribution_reassignments
      end
      include_context 'distribution_reassignments_constructor_examples'
    end
    describe :build_legislation_reassignments do
      before(:each) do
        @old_reassignments = input.legislation_reassignments
        constructor.build_legislation_reassignments
      end
      include_context 'legislation_reassignments_constructor_examples'
    end
    describe :build_common_names_reassignments do
      before(:each) do
        @old_reassignments = input.reassignments
        constructor.build_common_names_reassignments
      end
      include_context 'common_name_reassignments_constructor_examples'
    end
    describe :build_references_reassignments do
      before(:each) do
        @old_reassignments = input.reassignments
        constructor.build_references_reassignments
      end
      include_context 'reference_reassignments_constructor_examples'
    end
  end

end
