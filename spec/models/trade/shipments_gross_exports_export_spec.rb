require 'spec_helper'

describe Trade::ShipmentsGrossExportsExport do

  before(:each) do
    4.times { create(:shipment) }
  end

  describe :total_cnt do
    context "when internal" do
      subject { Trade::ShipmentsGrossExportsExport.new(:internal => true, :per_page => 4) }
      specify{ subject.total_cnt.should == 4 }
    end
    context "when public" do
      subject { Trade::ShipmentsGrossExportsExport.new(:internal => false, :per_page => 3) }
      specify{ subject.total_cnt.should == 4 }
    end
  end

  describe :query do
    context "when internal" do
      subject { Trade::ShipmentsGrossExportsExport.new(:internal => true, :per_page => 4) }
      specify{ subject.query.ntuples.should == 4 }
    end
    context "when public" do
      subject { Trade::ShipmentsGrossExportsExport.new(:internal => false, :per_page => 3) }
      specify{ subject.query.ntuples.should == 3 }
    end
  end

end