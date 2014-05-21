require 'spec_helper'

describe Trade::ShipmentsController do
  include_context 'Shipments'

  describe "GET index" do
    before(:each){ Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings }
    it "should return all shipments" do
      get :index, format: :json
      response.body.should have_json_size(6).at_path('shipments')
    end
    it "should return genus & species shipments when searching by genus" do
      get :index, taxon_concepts_ids: [@animal_genus.id], format: :json
      response.body.should have_json_size(2).at_path('shipments')
    end
    it "should return 1 shipment when searching for reporter_type I" do
      get :index, time_range_start: @shipment1.year, time_range_end: @shipment2.year,
        reporter_type: "E", exporters_ids: [@portugal.id.to_s], format: :json
      response.body.should have_json_size(1).at_path('shipments')
    end
  end

  describe "DELETE destroy_batch" do
    before(:each){ Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings }
    it "should delete 1 shipment" do
      delete :destroy_batch, {
        time_range_start: @shipment1.year,
        time_range_end: @shipment2.year,
        reporter_type: 'E',
        exporters_ids: [@portugal.id.to_s]}
      Trade::Shipment.count.should == 5
    end
    it "should delete 4 shipment" do
      delete :destroy_batch, {
        time_range_start: @shipment1.year,
        time_range_end: @shipment2.year,
        reporter_type: 'I',
        importers_ids: [@portugal.id.to_s]}
      Trade::Shipment.count.should == 1
    end
  end

  describe "DELETE destroy" do
    before(:each){ Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings }
    it "should delete 1 shipment" do
      delete :destroy_batch, id: @shipment1.id
      Trade::Shipment.where(id: @shipment1.id).should be_empty
    end
  end
end
