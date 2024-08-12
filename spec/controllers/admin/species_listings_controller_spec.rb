require 'spec_helper'

describe Admin::SpeciesListingsController do
  login_admin

  describe 'index' do
    it 'assigns @species_listings sorted by designation and name' do
      designation1 = create(:designation, name: 'BB', taxonomy: create(:taxonomy))
      designation2 = create(:designation, name: 'AA', taxonomy: create(:taxonomy))
      species_listing2_1 = create(:species_listing, designation: designation2, name: 'I')
      species_listing2_2 = create(:species_listing, designation: designation2, name: 'II')
      species_listing1 = create(:species_listing, designation: designation1, name: 'I')
      get :index
      expect(assigns(:species_listings)).to eq([ species_listing1, species_listing2_1, species_listing2_2 ])
    end
    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'XHR POST create' do
    it 'renders create when successful' do
      post :create, params: { species_listing: build_attributes(:species_listing) }, xhr: true
      expect(response).to render_template('create')
    end
    it 'renders new when not successful' do
      post :create, params: { species_listing: { dummy: 'test' } }, xhr: true
      expect(response).to render_template('new')
    end
  end

  describe 'XHR PUT update' do
    let(:species_listing) { create(:species_listing) }
    it 'responds with 200 when successful' do
      put :update, format: 'json', params: { id: species_listing.id, species_listing: { name: 'ZZ' } }, xhr: true
      expect(response).to be_successful
    end
    it 'responds with json when not successful' do
      put :update, format: 'json', params: { id: species_listing.id, species_listing: { name: nil } }, xhr: true
      expect(JSON.parse(response.body)).to include('errors')
    end
  end

  describe 'DELETE destroy' do
    let(:species_listing) { create(:species_listing) }
    it 'redirects after delete' do
      delete :destroy, params: { id: species_listing.id }
      expect(response).to redirect_to(admin_species_listings_url)
    end
  end
end
