require 'spec_helper'

describe CitesTrade::ShipmentsController do
  include_context 'Shipments'

  describe "GET index" do
    before(:each) { Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings }
    context "serializer" do
      it "should return comptab export when report_type invalid" do
        get :index, filters: {
          report_type: 'raw'
        }, format: :json
        response.body.should have_json_path('shipment_comptab_export')
      end
      it "should return comptab export when report_type = comptab" do
        get :index, filters: {
          report_type: 'comptab'
        }, format: :json
        response.body.should have_json_path('shipment_comptab_export')
      end
      it "should return gross net export when report_type = gross_exports" do
        get :index, filters: {
          report_type: 'gross_exports'
        }, format: :json
        response.body.should have_json_path('shipment_gross_net_export')
      end
    end
    it "should return all comptab shipments" do
      get :index, format: :json
      response.body.should have_json_size(7).at_path('shipment_comptab_export/rows')
    end
    it "should return all gross_exports shipments" do
      get :index, filters: {
        report_type: 'gross_exports',
        time_range_start: 2012,
        time_range_end: 2014
      }, format: :json
      response.body.should have_json_size(5).at_path('shipment_gross_net_export/rows')
    end
    it "should return genus & species shipments when searching by genus" do
      get :index, filters: {
        taxon_concepts_ids: [@animal_genus.id],
        selection_taxon: 'taxonomic_cascade'
      }, format: :json
      response.body.should have_json_size(2).at_path('shipment_comptab_export/rows')
    end
    it "should return family, genus & species shipments when searching by family" do
      get :index, filters: {
        taxon_concepts_ids: [@animal_family.id],
        selection_taxon: 'taxonomic_cascade'
      }, format: :json
      response.body.should have_json_size(3).at_path('shipment_comptab_export/rows')
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
