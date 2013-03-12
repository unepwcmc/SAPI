require 'spec_helper'

describe CitesCop do
  describe :create do
    context "when designation invalid" do
      let(:cites_cop){
        build(
          :cites_cop,
          :designation => Designation.find_or_create_by_name('EU')
        )
      }
      specify { cites_cop.should be_invalid}
      specify { cites_cop.should have(1).error_on(:designation_id) }
    end
  end
end
