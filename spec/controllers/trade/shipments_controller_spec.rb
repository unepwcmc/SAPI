require 'spec_helper'

describe Trade::ShipmentsController, sidekiq: :inline do
  login_admin

  include_context 'Shipments'

  describe 'GET index' do
    before(:each) { SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings }
    it 'should return all shipments' do
      get :index, format: :json
      expect(response.body).to have_json_size(7).at_path('shipments')
    end
    it 'should return genus & species shipments when searching by genus' do
      get :index, params: { taxon_concepts_ids: [ @animal_genus.id ], format: :json }
      expect(response.body).to have_json_size(2).at_path('shipments')
    end

    it 'should return 1 shipment when searching for reporter_type I' do
      get :index, params: { time_range_start: @shipment1.year, time_range_end: @shipment2.year, reporter_type: 'E', exporters_ids: [ @portugal.id.to_s ], format: :json }
      expect(response.body).to have_json_size(1).at_path('shipments')
    end
  end

  describe 'PUT update' do
    before(:each) { SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings }
    it 'should auto resolve accepted taxon when blank' do
      put :update, params: { id: @shipment1.id, shipment: {
        reported_taxon_concept_id: @synonym_subspecies.id
      } }
      expect(@shipment1.reload.taxon_concept_id).to eq(@plant_species.id)
    end
    it 'should not auto resolve accepted taxon when given' do
      put :update, params: { id: @shipment1.id, shipment: {
        reported_taxon_concept_id: @synonym_subspecies.id,
        taxon_concept_id: @animal_species.id
      } }
      expect(@shipment1.reload.taxon_concept_id).to eq(@animal_species.id)
    end
    it 'should delete orphaned permits' do
      put :update, params: { id: @shipment1.id, shipment: {
        import_permit_number: 'YYY'
      } }
      expect(Trade::Permit.find_by(id: @import_permit.id)).to be_nil
    end
  end

  describe 'POST update_batch' do
    before(:each) { SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings }
    it 'should change reporter type from I to E' do
      post :update_batch, params: { filters: { # shipment2
        time_range_start: @shipment1.year,
        time_range_end: @shipment2.year,
        reporter_type: 'I',
        exporters_ids: [ @portugal.id.to_s, @argentina.id.to_s ],
        importers_ids: [ @portugal.id.to_s, @argentina.id.to_s ],
        taxon_concepts_ids: [ @plant_species.id ]
      }, updates: {
        reporter_type: 'E'
      } }
      expect(@shipment1.reported_by_exporter).to be_truthy
      expect(@shipment2.reload.reported_by_exporter).to be_truthy
    end
    it 'should change reporter type from E to I' do
      post :update_batch, params: { filters: { # shipment1
        time_range_start: @shipment1.year,
        time_range_end: @shipment2.year,
        reporter_type: 'E',
        exporters_ids: [ @portugal.id.to_s, @argentina.id.to_s ],
        importers_ids: [ @portugal.id.to_s, @argentina.id.to_s ]
      }, updates: {
        reporter_type: 'I'
      } }

      expect(@shipment1.reload.reported_by_exporter).to be_falsey
      expect(@shipment2.reported_by_exporter).to be_falsey
    end

    it 'should update year' do
      post :update_batch, params: { filters: { # shipment1
        time_range_start: @shipment1.year,
        time_range_end: @shipment2.year,
        year: 2013,
        exporters_ids: [ @portugal.id.to_s, @argentina.id.to_s ],
        importers_ids: [ @portugal.id.to_s, @argentina.id.to_s ]
      }, updates: {
        year: 2014
      } }
      expect(Trade::Shipment.where(year: 2013).count).to eq(0)
      expect(Trade::Shipment.where(year: 2014).count).to be > 0
    end

    it 'should auto resolve accepted taxon when blank' do
      post :update_batch, params: { filters: { # shipment1
        time_range_start: @shipment1.year,
        time_range_end: @shipment2.year,
        year: 2013,
        exporters_ids: [ @portugal.id.to_s, @argentina.id.to_s ],
        importers_ids: [ @portugal.id.to_s, @argentina.id.to_s ]
      }, updates: {
        reported_taxon_concept_id: @synonym_subspecies.id
      } }
      expect(@shipment1.reload.taxon_concept_id).to eq(@plant_species.id)
    end

    it 'should not auto resolve accepted taxon when given' do
      post :update_batch, params: { filters: { # shipment1
        time_range_start: @shipment1.year,
        time_range_end: @shipment2.year,
        year: 2013,
        exporters_ids: [ @portugal.id.to_s, @argentina.id.to_s ],
        importers_ids: [ @portugal.id.to_s, @argentina.id.to_s ]
      }, updates: {
        reported_taxon_concept_id: @synonym_subspecies.id,
        taxon_concept_id: @animal_species.id
      } }
      expect(@shipment1.reload.taxon_concept_id).to eq(@animal_species.id)
    end

    it 'should set permit number to blank and delete orphaned permits' do
      post :update_batch, params: { filters: { # shipment1
        time_range_start: @shipment1.year,
        time_range_end: @shipment2.year,
        year: 2013,
        exporters_ids: [ @portugal.id.to_s, @argentina.id.to_s ],
        importers_ids: [ @portugal.id.to_s, @argentina.id.to_s ]
      }, updates: {
        import_permit_number: nil
      } }
      expect(@shipment1.reload.import_permits_ids).to be_blank
      expect(@shipment1.import_permit_number).to be_nil
      expect(Trade::Permit.find_by(id: @import_permit.id)).to be_nil
    end
  end

  describe 'POST destroy_batch' do
    before(:each) { SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings }
    it 'should delete 1 shipment' do
      post :destroy_batch, params: { time_range_start: @shipment1.year, time_range_end: @shipment2.year, reporter_type: 'E', exporters_ids: [ @portugal.id.to_s, @argentina.id.to_s ], importers_ids: [ @portugal.id.to_s, @argentina.id.to_s ], taxon_concepts_ids: [ @animal_species.id ] }
      expect(Trade::Shipment.count).to eq(6)
    end
    it 'should delete 5 shipment' do
      post :destroy_batch, params: { time_range_start: @shipment1.year, time_range_end: @shipment2.year, reporter_type: 'I', exporters_ids: [ @portugal.id.to_s, @argentina.id.to_s ], importers_ids: [ @portugal.id.to_s, @argentina.id.to_s ] }
      expect(Trade::Shipment.count).to eq(2)
    end

    it 'should delete 2 shipments' do
      post :destroy_batch, params: { importers_ids: [ @argentina.id.to_s ] }
      expect(Trade::Shipment.count).to eq(5)
    end

    it 'should delete 1 shipments' do
      post :destroy_batch, params: { exporters_ids: [ @portugal.id.to_s ] }
      expect(Trade::Shipment.count).to eq(5)
    end

    it 'should delete all shipments' do
      post :destroy_batch, params: { purposes_ids: [ @purpose.id.to_s ] }
      expect(Trade::Shipment.count).to eq(0)
    end

    it "shouldn't delete any shipments" do
      post :destroy_batch, params: { purpose_blank: 'true' }
      expect(Trade::Shipment.count).to eq(7)
    end

    it 'should delete 1 shipment' do
      post :destroy_batch, params: { sources_ids: [ @source.id.to_s ] }
      expect(Trade::Shipment.count).to eq(5)
    end

    it 'should delete 3 shipment' do
      post :destroy_batch, params: { sources_ids: [ @source_wild.id.to_s ] }
      expect(Trade::Shipment.count).to eq(4)
    end

    it 'should delete 0 shipments' do
      post :destroy_batch, params: { sources_ids: [ @source_wild.id.to_s ], reporter_type: 'E' }
      expect(Trade::Shipment.count).to eq(7)
    end

    it 'should delete 4 shipments' do
      post :destroy_batch, params: { sources_ids: [ @source_wild.id.to_s ], reporter_type: 'I', source_blank: 'true' }
      expect(Trade::Shipment.count).to eq(3)
    end

    it 'should delete orphaned permits' do
      post :destroy_batch, params: { time_range_start: @shipment1.year, time_range_end: @shipment2.year, year: 2013, exporters_ids: [ @portugal.id.to_s, @argentina.id.to_s ], importers_ids: [ @portugal.id.to_s, @argentina.id.to_s ] }
      expect(Trade::Shipment.find_by(id: @shipment1.id)).to be_nil
      expect(Trade::Permit.find_by(id: @import_permit.id)).to be_nil
    end
  end

  describe 'DELETE destroy' do
    before(:each) { SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings }
    it 'should delete 1 shipment' do
      delete :destroy, params: { id: @shipment1.id }
      expect(Trade::Shipment.where(id: @shipment1.id)).to be_empty
    end
    it 'should delete orphaned permits' do
      delete :destroy, params: { id: @shipment1.id }
      expect(Trade::Permit.find_by(id: @import_permit.id)).to be_nil
    end
  end
end
