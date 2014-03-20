require 'spec_helper'

describe CitesTrade::ShipmentsController do
  include_context 'Shipments'

  describe "GET index" do
    before(:each){ Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings }
    it "should return all comptab shipments" do
      get :index, format: :json
      response.body.should have_json_size(6).at_path('shipment_comptab_export/rows')
    end
    it "should return all gross_exports shipments" do
      get :index, filters: {
        report_type: 'gross_exports',
        time_range_start: 2012,
        time_range_end: 2013,
      }, format: :json
      response.body.should have_json_size(4).at_path('shipment_gross_net_export/rows')
    end
    it "should return genus & species shipments when searching by genus" do
      get :index, filters: {
        taxon_concepts_ids: [@animal_genus.id],
        selection_taxon: 'genus'
      }, format: :json
      response.body.should have_json_size(2).at_path('shipment_comptab_export/rows')
    end
    it "should return genus shipments when searching by taxon" do
      get :index, filters: {
        taxon_concepts_ids: [@animal_genus.id],
        selection_taxon: 'taxon'
      }, format: :json
      response.body.should have_json_size(0).at_path('shipment_comptab_export/rows')
    end
  end

end