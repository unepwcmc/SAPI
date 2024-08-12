require 'spec_helper'

describe Admin::DistributionsController do
  login_admin

  before do
    @taxon_concept = create(:taxon_concept)
  end
  describe "XHR GET 'new'" do
    it 'returns http success and renders the new template' do
      get :new, params: { taxon_concept_id: @taxon_concept.id }, xhr: true
      expect(response).to be_successful
      expect(response).to render_template('new')
    end
    it 'assigns @geo_entities (country and territory) with two objects' do
      geo_entity_type_t = create(:geo_entity_type, name: 'TERRITORY')
      territory = create(:geo_entity, geo_entity_type_id: geo_entity_type_t.id)
      country = create(:geo_entity)
      get :new, params: { taxon_concept_id: @taxon_concept.id }, xhr: true
      expect(assigns(:geo_entities).size).to eq(2)
    end
    it 'assigns the distribution variable' do
      get :new, params: { taxon_concept_id: @taxon_concept.id }, xhr: true
      expect(assigns(:distribution)).not_to be_nil
      expect(assigns(:tags)).not_to be_nil
      expect(assigns(:geo_entities)).not_to be_nil
    end
  end

  describe "XHR POST 'create'" do
    let(:geo_entity) { create(:geo_entity) }
    let(:reference) { create(:reference) }
    it 'renders create when successful and has an existing reference' do
      post :create, xhr: true,
        params: {
          taxon_concept_id: @taxon_concept.id,
          distribution: {
            geo_entity_id: geo_entity.id
          },
          reference: {
            reference_id: reference.id
          }
        }
      expect(response).to render_template('create')
    end
    it 'renders create when successful and is creating a reference' do
      post :create, xhr: true,
        params: {
          taxon_concept_id: @taxon_concept.id,
          distribution: {
            geo_entity_id: geo_entity.id
          },
          reference: {
            title: reference.title,
            author: reference.author,
            year: reference.year
          }
        }
      expect(response).to render_template('create')
    end
  end

  describe 'XHR GET edit' do
    let(:distribution) { create(:distribution, taxon_concept_id: @taxon_concept.id) }
    it 'renders the new template' do
      get :edit, params: { taxon_concept_id: @taxon_concept.id, id: distribution.id }, xhr: true
      expect(response).to render_template('new')
    end
    it 'assigns the distribution variable' do
      get :edit, params: { taxon_concept_id: @taxon_concept.id, id: distribution.id }, xhr: true
      expect(assigns(:distribution)).not_to be_nil
    end
    it 'assigns @geo_entities (country and territory) with two objects' do
      geo_entity_type_t = create(:geo_entity_type, name: 'TERRITORY')
      territory = create(:geo_entity, geo_entity_type_id: geo_entity_type_t.id)
      get :edit, params: { taxon_concept_id: @taxon_concept.id, id: distribution.id }, xhr: true
      expect(assigns(:geo_entities).size).to eq(2)
    end
  end

  describe 'XHR PUT update' do
    let(:distribution) { create(:distribution, taxon_concept_id: @taxon_concept.id) }
    let(:geo_entity) { create(:geo_entity) }
    it 'responds with 200 when successful' do
      put :update, format: 'json', xhr: true,
        params: {
          taxon_concept_id: @taxon_concept.id,
          id: distribution.id,
          distribution: {
            geo_entity_id: geo_entity.id
          }
        }
      expect(response).to be_successful
    end
  end

  describe 'DELETE destroy' do
    let(:distribution) { create(:distribution, taxon_concept_id: @taxon_concept.id) }
    it 'redirects after delete' do
      delete :destroy, params: { taxon_concept_id: @taxon_concept.id, id: distribution.id }
      expect(response).to redirect_to(
        admin_taxon_concept_distributions_url(distribution.taxon_concept)
      )
    end
  end
end
