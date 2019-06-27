require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the AdminHelper. For example:
#
# describe AdminHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe Admin::NomenclatureChangesHelper, type: :helper do
  describe 'split_blurb' do
    include_context 'split_definitions'
    context "split with input" do
      before(:each) { @nomenclature_change = split_with_input }
      specify { expect(helper.split_blurb).to match(@nomenclature_change.input.taxon_concept.full_name) }
    end
    context "split with outputs" do
      before(:each) { @nomenclature_change = split_with_input_and_output }
      specify { expect(helper.split_blurb).to match(@nomenclature_change.outputs.first.taxon_concept.full_name) }
    end
    context "split with output new taxon" do
      before(:each) { @nomenclature_change = split_with_input_and_output_new_taxon }
      specify { expect(helper.split_blurb).to match(@nomenclature_change.outputs.first.display_full_name) }
    end
  end
  describe 'lump_blurb' do
    include_context 'lump_definitions'
    context "lump with inputs" do
      before(:each) { @nomenclature_change = lump_with_inputs }
      specify { expect(helper.lump_blurb).to match(@nomenclature_change.inputs.first.taxon_concept.full_name) }
    end
    context "lump with output" do
      before(:each) { @nomenclature_change = lump_with_inputs_and_output }
      specify { expect(helper.lump_blurb).to match(@nomenclature_change.output.taxon_concept.full_name) }
    end
    context "lump with output new taxon" do
      before(:each) { @nomenclature_change = lump_with_inputs_and_output_new_taxon }
      specify { expect(helper.lump_blurb).to match(@nomenclature_change.output.display_full_name) }
    end
  end
  describe 'status_change_blurb' do
    include_context 'status_change_definitions'
    context "status upgrade with primary output" do
      before(:each) { @nomenclature_change = t_to_a_with_primary_output }
      specify { expect(helper.status_change_blurb).to match(@nomenclature_change.primary_output.taxon_concept.full_name) }
    end
    context "status upgrade with swap" do
      before(:each) { @nomenclature_change = a_to_s_with_swap }
      specify { expect(helper.status_change_blurb).to match(@nomenclature_change.secondary_output.taxon_concept.full_name) }
    end
  end

end
