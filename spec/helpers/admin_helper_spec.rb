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
describe AdminHelper, type: :helper do
  describe 'edit_icon' do
    it "ouputs pencil icon for edit" do
      expect(helper.edit_icon).to eq('<i class="icon-pencil" title="Edit"></i>')
    end
  end
  describe 'delete_icon' do
    it "ouputs bin icon for delete" do
      expect(helper.delete_icon).to eq('<i class="icon-trash" title="Delete"></i>')
    end
  end
  describe 'true_false_icon' do
    it "outputs tick icon for true" do
      expect(helper.true_false_icon(true)).to eq('<i class="icon-ok"></i>')
    end
    it "outputs blank for false" do
      expect(helper.true_false_icon(false)).to be_blank
    end
  end

end
