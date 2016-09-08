require 'spec_helper'

describe Admin::GeoEntitiesController do
  login_admin

  describe "index" do
    before(:each) do
      @geo_entity1 = create(
        :geo_entity,
        geo_entity_type: country_geo_entity_type,
        name_en: 'BB',
        iso_code2: 'BB'
      )
      @geo_entity2 = create(
        :geo_entity,
        geo_entity_type: country_geo_entity_type,
        name_en: 'AA',
        iso_code2: 'AA'
      )
    end

    describe "GET index" do
      it "assigns @geo_entities sorted by name" do
        get :index
        assigns(:geo_entities).should eq([@geo_entity2, @geo_entity1])
      end
      it "renders the index template" do
        get :index
        response.should render_template("index")
      end
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create, geo_entity: {
        geo_entity_type_id: country_geo_entity_type.id,
        name_en: 'CC',
        iso_code2: 'CC'
      }
      response.should render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create, geo_entity: {
        geo_entity_type_id: country_geo_entity_type.id,
        iso_code2: nil
      }
      response.should render_template("new")
    end
  end

  describe "XHR PUT update JSON" do
    let(:geo_entity) { create(:geo_entity, geo_entity_type: country_geo_entity_type) }
    it "responds with 200 when successful" do
      xhr :put, :update, format: 'json', id: geo_entity.id, geo_entity: { iso_code2: 'ZZ' }
      response.should be_success
    end
    it "responds with json when not successful" do
      xhr :put, :update, format: 'json', id: geo_entity.id, geo_entity: { iso_code2: nil }
      JSON.parse(response.body).should include('errors')
    end
  end

  describe "DELETE destroy" do
    let(:geo_entity) { create(:geo_entity) }
    it "redirects after delete" do
      delete :destroy, id: geo_entity.id
      response.should redirect_to(admin_geo_entities_url)
    end
  end

end
