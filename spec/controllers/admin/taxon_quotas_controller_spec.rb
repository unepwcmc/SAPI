require 'spec_helper'

describe Admin::TaxonQuotasController do
  login_admin

  before do
    @taxon_concept = create(:taxon_concept)
    @unit = create(:unit)
    @geo_entity = create(:geo_entity)
  end

  describe 'GET index' do
    it 'renders the index template' do
      get :index, params: { taxon_concept_id: @taxon_concept.id }
      expect(response).to render_template('index')
    end
    it 'renders the taxon_concepts_layout' do
      get :index, params: { taxon_concept_id: @taxon_concept.id }
      expect(response).to render_template('layouts/taxon_concepts')
    end
  end

  describe 'GET new' do
    it 'renders the new template' do
      get :new, params: { taxon_concept_id: @taxon_concept.id }
      expect(response).to render_template('new')
    end
    it 'assigns @geo_entities (country and territory) with two objects' do
      geo_entity_type_t = create(:geo_entity_type, name: 'TERRITORY')
      territory = create(:geo_entity, geo_entity_type_id: geo_entity_type_t.id)
      get :new, params: { taxon_concept_id: @taxon_concept.id }
      expect(assigns(:geo_entities).size).to eq(2)
    end
  end

  describe 'POST create' do
    context 'when successful' do
      it 'renders index' do
        post :create, params: {
          quota: {
            quota: 1,
            unit_id: @unit.id,
            publication_date: 1.week.ago,
            geo_entity_id: @geo_entity.id
          }, taxon_concept_id: @taxon_concept.id
        }
        expect(response).to redirect_to(
          admin_taxon_concept_quotas_url(@taxon_concept)
        )
      end
    end
    it 'renders new when not successful' do
      post :create, params: { quota: { dummy: 'test' }, taxon_concept_id: @taxon_concept.id }
      expect(response).to render_template('new')
    end
  end

  describe 'GET edit' do
    before(:each) do
      @quota = create(
        :quota,
        unit_id: @unit.id,
        taxon_concept_id: @taxon_concept.id,
        geo_entity_id: @geo_entity.id
      )
    end
    it 'renders the edit template' do
      get :edit, params: { id: @quota.id, taxon_concept_id: @taxon_concept.id }
      expect(response).to render_template('edit')
    end
    it 'assigns @geo_entities (country and territory) with two objects' do
      geo_entity_type_t = create(:geo_entity_type, name: 'TERRITORY')
      territory = create(:geo_entity, geo_entity_type_id: geo_entity_type_t.id)
      get :edit, params: { id: @quota.id, taxon_concept_id: @taxon_concept.id }
      expect(assigns(:geo_entities).size).to eq(2)
    end
  end

  describe 'PUT update' do
    before(:each) do
      @quota = create(
        :quota,
        unit_id: @unit.id,
        taxon_concept_id: @taxon_concept.id,
        geo_entity_id: @geo_entity.id
      )
    end

    context 'when successful' do
      it 'renders taxon_concepts quotas page' do
        put :update, params: {
          quota: {
            publication_date: 1.week.ago
          }, id: @quota.id, taxon_concept_id: @taxon_concept.id
        }
        expect(response).to redirect_to(
          admin_taxon_concept_quotas_url(@taxon_concept)
        )
      end
    end

    it 'renders new when not successful' do
      put :update, params: {
        quota: {
          publication_date: nil
        }, id: @quota.id, taxon_concept_id: @taxon_concept.id
      }
      expect(response).to render_template('new')
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @quota = create(
        :quota,
        unit_id: @unit.id,
        taxon_concept_id: @taxon_concept.id,
        geo_entity_id: @geo_entity.id
      )
    end
    it 'redirects after delete' do
      delete :destroy, params: { id: @quota.id, taxon_concept_id: @taxon_concept.id }
      expect(response).to redirect_to(
        admin_taxon_concept_quotas_url(@taxon_concept)
      )
    end
  end

  describe 'Authorization for contributors' do
    login_contributor
    let!(:quota) do
      create(
        :quota,
        unit_id: @unit.id,
        taxon_concept_id: @taxon_concept.id,
        geo_entity_id: @geo_entity.id
      )
    end
    describe 'GET index' do
      it 'renders the index template' do
        get :index, params: { taxon_concept_id: @taxon_concept.id }
        expect(response).to render_template('index')
      end
      it 'renders the taxon_concepts_layout' do
        get :index, params: { taxon_concept_id: @taxon_concept.id }
        expect(response).to render_template('layouts/taxon_concepts')
      end
    end
    describe 'DELETE destroy' do
      it 'fails to delete and redirects' do
        @request.env['HTTP_REFERER'] = admin_taxon_concept_quotas_url(@taxon_concept)
        delete :destroy, params: { id: quota.id, taxon_concept_id: @taxon_concept.id }
        expect(response).to redirect_to(
          admin_taxon_concept_quotas_url(@taxon_concept)
        )
        expect(Quota.find(quota.id)).not_to be_nil
      end
    end
  end
end
