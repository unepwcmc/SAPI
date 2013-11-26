require 'spec_helper'

describe Trade::ExportsController do
  describe "GET download" do
    context "raw format" do
      it "returns count of shipments" do
        create(:shipment)
        get :download, :filters => {:report_type => 'raw'}, :format => :json
        parse_json(response.body)['total'].should == 1
      end
      it "returns raw shipments file" do
        create(:shipment)
        Trade::ShipmentsExport.any_instance.stub(:public_file_name).and_return('shipments.csv')
        get :download, :filters => {:report_type => :raw}
        response.content_type.should eq("text/csv")
        response.headers["Content-Disposition"].should eq("attachment; filename=\"shipments.csv\"")
      end
      # it "when no results" do
      #   get :download, :filters => {:report_type => :raw}
      #   puts response.body.inspect
      #   response.code.should eql(204)
      # end
    end


  end
end
