require 'spec_helper'

describe Document do
  describe :create do
    context "when date is blank" do
      let(:document){
        build(
          :document,
          :date => nil
        )
      }
      specify { document.should be_invalid}
      specify { document.should have(1).error_on(:date) }
    end
  end
end