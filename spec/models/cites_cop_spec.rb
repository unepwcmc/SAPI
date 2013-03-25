require 'spec_helper'

describe CitesCop do
  describe :create do
    context "when designation invalid" do
      let(:cites_cop){
        build(
          :cites_cop,
          :designation => eu
        )
      }
      specify { cites_cop.should be_invalid}
      specify { cites_cop.should have(1).error_on(:designation_id) }
    end
  end
end
