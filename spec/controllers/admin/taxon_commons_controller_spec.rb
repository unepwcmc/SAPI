require 'spec_helper'

describe Admin::TaxonCommonsController do
  login_admin

  before do
    @taxon_concept = create(:taxon_concept)
    @common_name = create(:common_name)
  end

  describe "XHR GET 'new'" do
    it "returns http success and renders the new template" do
      xhr :get, :new, { :taxon_concept_id => @taxon_concept.id, :format => 'js' }
      response.should be_success
      response.should render_template('new')
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create,
        :taxon_concept_id => @taxon_concept.id,
        :taxon_common => {
          :name => @common_name.name,
          :language_id => @common_name.language_id
        }
      response.should render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create,
        :taxon_concept_id => @taxon_concept.id,
        :taxon_common => {
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
          :name => @common_name.name,
          :language_id => @common_name.language_id
        }
      response.should render_template("create")
    end
    it "renders new when not successful" do
      xhr :put, :update, :format => 'js',
        :taxon_concept_id => @taxon_concept.id,
        :id => @taxon_common.id,
        :taxon_common => {
          :common_name_id => nil
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
        admin_taxon_concept_names_url(@taxon_concept)
      )
    end
  end

  describe "ChangeObserver updates TaxonConcept's dependents_updated_at
    when TaxonCommon is changed" do

    before do
      @taxon_common = create(
        :taxon_common,
        :common_name_id => @common_name.id,
        :taxon_concept_id => @taxon_concept.id
      )
    end

    it "updates associated @taxon_concept's
      dependents_updated_at when taxon common is updated" do

      @taxon_concept.dependents_updated_at.should be_nil

      # it gets updated by the creation of the taxon_common
      # but object needs to be reloaded
      @taxon_concept.reload.dependents_updated_at.should_not be_nil
      old_date = @taxon_concept.dependents_updated_at

      xhr :put, :update, :format => 'js',
        :taxon_concept_id => @taxon_concept.id,
        :id => @taxon_common.id,
        :taxon_common => {
          :name => @common_name.name,
          :language_id => @common_name.language_id
        }

      @taxon_concept.reload.dependents_updated_at.should_not == old_date
    end

    it "updates associated @taxon_concept's
      dependents_updated_at when taxon common is deleted" do

      @taxon_concept.dependents_updated_at.should be_nil

      # it gets updated by the creation of the taxon_common
      # but object needs to be reloaded
      @taxon_concept.reload.dependents_updated_at.should_not be_nil
      old_date = @taxon_concept.dependents_updated_at

      delete :destroy,
        :taxon_concept_id => @taxon_concept.id,
        :id => @taxon_common.id

      @taxon_concept.reload.dependents_updated_at.should_not == old_date
      TaxonCommon.where(:id => @taxon_common.id).size.should == 0
    end
  end

  describe "Authorization for contributors" do
    login_contributor
    let(:taxon_common) {
      create(
        :taxon_common,
        :taxon_concept_id => @taxon_concept.id,
        :common_name => @common_name
      )
    }
    describe "DELETE destroy" do
      it "fails to delete and redirects" do
        @request.env['HTTP_REFERER'] = admin_taxon_concept_names_url(@taxon_concept)
        delete :destroy, :id => taxon_common.id,
          :taxon_concept_id => @taxon_concept.id
        response.should redirect_to(
          admin_taxon_concept_names_url(@taxon_concept)
        )
        TaxonCommon.find(taxon_common.id).should_not be_nil
      end
    end
  end
end
