require 'spec_helper'

describe Admin::TaxonCommonsController do
  before do
    @taxon_concept = create(:taxon_concept)
    @common_name = create(:common_name)
  end

  describe "XHR GET 'new'" do
    it "returns http success and renders the new template" do
      xhr :get, :new, {:taxon_concept_id => @taxon_concept.id, :format => 'js'}
      response.should be_success
      response.should render_template('new')
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create,
        :taxon_concept_id => @taxon_concept.id,
        :taxon_common => {
          :common_name_attributes =>
            build_attributes(:common_name)
        }
      response.should render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create,
        :taxon_concept_id => @taxon_concept.id,
        :taxon_common => {
          :common_name_attributes => {}
        }
      response.should render_template("new")
    end
  end

  describe "XHR GET edit" do
    before do
      @taxon_common = create(
        :taxon_common,
        :common_name_id => @common_name.id,
        :taxon_concept_id => @taxon_concept.id
      )
    end
    it "renders the edit template" do
      xhr :get, :edit, :taxon_concept_id => @taxon_concept.id,
        :id => @taxon_common.id
      response.should render_template('new')
    end
    it "assigns the  taxon common variable" do
      xhr :get, :edit, :taxon_concept_id => @taxon_concept.id,
        :id => @taxon_common.id
      assigns(:taxon_common).should_not be_nil
    end
  end

  describe "XHR PUT update" do
    before do
      @taxon_common = create(
        :taxon_common,
        :common_name_id => @common_name.id,
        :taxon_concept_id => @taxon_concept.id
      )
    end
    it "renders create when successful" do
      xhr :put, :update, :format => 'js',
        :taxon_concept_id => @taxon_concept.id,
        :id => @taxon_common.id,
        :taxon_common => {
          :common_name_attributes =>
            build_attributes(:common_name)
        }
      response.should render_template("create")
    end
    it "renders new when not successful" do
      xhr :put, :update, :format => 'js',
        :taxon_concept_id => @taxon_concept.id,
        :id => @taxon_common.id,
        :taxon_common => {
          :common_name_attributes => {}
        }
      response.should render_template('new')
    end
  end

  describe "DELETE destroy" do
    let(:taxon_common) {
      create(
        :taxon_common,
        :taxon_concept_id => @taxon_concept.id,
        :common_name => @common_name
      )
    }
    it "redirects after delete" do
      delete :destroy,
        :taxon_concept_id => @taxon_concept.id,
        :id => taxon_common.id
      response.should redirect_to(
        edit_admin_taxon_concept_url(@taxon_concept)
      )
    end
  end
end
