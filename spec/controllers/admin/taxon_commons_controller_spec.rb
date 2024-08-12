require 'spec_helper'

describe Admin::TaxonCommonsController do
  login_admin

  before do
    @taxon_concept = create(:taxon_concept)
    @common_name = create(:common_name)
  end

  describe "XHR GET 'new'" do
    it "returns http success and renders the new template" do
      get :new, params: { taxon_concept_id: @taxon_concept.id, format: 'js' }, xhr: true
      expect(response).to be_successful
      expect(response).to render_template('new')
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      post :create, xhr: true,
        params: {
          taxon_concept_id: @taxon_concept.id,
          taxon_common: {
            name: @common_name.name,
            language_id: @common_name.language_id
          }
        }
      expect(response).to render_template("create")
    end
    it "renders new when not successful" do
      post :create, xhr: true,
        params: {
          taxon_concept_id: @taxon_concept.id,
          taxon_common: { dummy: 'test' }
        }
      expect(response).to render_template("new")
    end
  end

  describe "XHR GET edit" do
    before do
      @taxon_common = create(
        :taxon_common,
        common_name_id: @common_name.id,
        taxon_concept_id: @taxon_concept.id
      )
    end
    it "renders the edit template" do
      get :edit, params: { taxon_concept_id: @taxon_concept.id, id: @taxon_common.id }, xhr: true
      expect(response).to render_template('new')
    end
    it "assigns the  taxon common variable" do
      get :edit, params: { taxon_concept_id: @taxon_concept.id, id: @taxon_common.id }, xhr: true
      expect(assigns(:taxon_common)).not_to be_nil
    end
  end

  describe "XHR PUT update" do
    before do
      @taxon_common = create(
        :taxon_common,
        common_name_id: @common_name.id,
        taxon_concept_id: @taxon_concept.id
      )
    end
    it "renders create when successful" do
      put :update, format: 'js', xhr: true,
        params: {
          taxon_concept_id: @taxon_concept.id,
          id: @taxon_common.id,
          taxon_common: {
            name: @common_name.name,
            language_id: @common_name.language_id
          }
        }
      expect(response).to render_template("create")
    end
    it "renders new when not successful" do
      put :update, format: 'js', xhr: true,
        params: {
          taxon_concept_id: @taxon_concept.id,
          id: @taxon_common.id,
          taxon_common: {
            common_name_id: nil
          }
        }
      expect(response).to render_template('new')
    end
  end

  describe "DELETE destroy" do
    let(:taxon_common) {
      create(
        :taxon_common,
        taxon_concept_id: @taxon_concept.id,
        common_name: @common_name
      )
    }
    it "redirects after delete" do
      delete :destroy, params: { taxon_concept_id: @taxon_concept.id, id: taxon_common.id }
      expect(response).to redirect_to(
        admin_taxon_concept_names_url(@taxon_concept)
      )
    end
  end

  describe "ChangeObserver updates TaxonConcept's dependents_updated_at
    when TaxonCommon is changed" do

    before do
      @taxon_common = create(
        :taxon_common,
        common_name_id: @common_name.id,
        taxon_concept_id: @taxon_concept.id
      )
    end

    it "updates associated @taxon_concept's
      dependents_updated_at when taxon common is updated" do

      expect(@taxon_concept.dependents_updated_at).to be_nil

      # it gets updated by the creation of the taxon_common
      # but object needs to be reloaded
      expect(@taxon_concept.reload.dependents_updated_at).not_to be_nil
      old_date = @taxon_concept.dependents_updated_at

      put :update, format: 'js', xhr: true,
        params: {
          taxon_concept_id: @taxon_concept.id,
          id: @taxon_common.id,
          taxon_common: {
            name: @common_name.name,
            language_id: @common_name.language_id
          }
        }

      expect(@taxon_concept.reload.dependents_updated_at).not_to eq(old_date)
    end

    it "updates associated @taxon_concept's
      dependents_updated_at when taxon common is deleted" do

      expect(@taxon_concept.dependents_updated_at).to be_nil

      # it gets updated by the creation of the taxon_common
      # but object needs to be reloaded
      expect(@taxon_concept.reload.dependents_updated_at).not_to be_nil
      old_date = @taxon_concept.dependents_updated_at

      delete :destroy, params: { taxon_concept_id: @taxon_concept.id, id: @taxon_common.id }

      expect(@taxon_concept.reload.dependents_updated_at).not_to eq(old_date)
      expect(TaxonCommon.where(id: @taxon_common.id).size).to eq(0)
    end
  end

  describe "Authorization for contributors" do
    login_contributor
    let(:taxon_common) {
      create(
        :taxon_common,
        taxon_concept_id: @taxon_concept.id,
        common_name: @common_name
      )
    }
    describe "DELETE destroy" do
      it "fails to delete and redirects" do
        @request.env['HTTP_REFERER'] = admin_taxon_concept_names_url(@taxon_concept)
        delete :destroy, params: { id: taxon_common.id, taxon_concept_id: @taxon_concept.id }
        expect(response).to redirect_to(
          admin_taxon_concept_names_url(@taxon_concept)
        )
        expect(TaxonCommon.find(taxon_common.id)).not_to be_nil
      end
    end
  end
end
