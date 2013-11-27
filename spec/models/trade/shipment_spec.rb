require 'spec_helper'

describe Trade::Shipment do

  describe :create do
    context "when reporter_type not given" do
      subject { build(:shipment, :reporter_type => nil) }
      specify { subject.should have(2).error_on(:reporter_type) }
    end
  end

end