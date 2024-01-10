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
      helper.edit_icon.should == '<i class="icon-pencil" title="Edit"></i>'
    end
  end
  describe 'delete_icon' do
    it "ouputs bin icon for delete" do
      helper.delete_icon.should == '<i class="icon-trash" title="Delete"></i>'
    end
  end
  describe 'true_false_icon' do
    it "outputs tick icon for true" do
      helper.true_false_icon(true).should == '<i class="icon-ok"></i>'
    end
    it "outputs blank for false" do
      helper.true_false_icon(false).should be_blank
    end
  end

end
