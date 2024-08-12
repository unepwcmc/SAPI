require 'spec_helper'

describe Admin::TaxonConceptReferencesController do
  login_admin

  before do
    @taxon_concept = create(:taxon_concept)
    @reference = create(:reference)
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      post :create, xhr: true, params: {
        taxon_concept_id: @taxon_concept.id,
        taxon_concept_reference: {
          reference_attributes:             { citation: "My nice literature" }
        }
      }
      expect(response).to render_template("create")
    end
    it "renders new when not successful" do
      post :create, xhr: true, params: {
        taxon_concept_id: @taxon_concept.id,
        taxon_concept_reference: {
          reference_attributes: {
            dummy: 'test'
          }
        }
      }
      expect(response).to render_template("new")
    end
  end

  describe "XHR GET edit" do
    before do
      @taxon_concept_reference = create(
        :taxon_concept_reference,
        reference_id: @reference.id,
        taxon_concept_id: @taxon_concept.id
      )
    end
    it "renders the edit template" do
      get :edit, params: { taxon_concept_id: @taxon_concept.id, id: @taxon_concept_reference.id }, xhr: true
      expect(response).to render_template('new')
    end
    it "assigns the  taxon concept reference variable" do
      get :edit, params: { taxon_concept_id: @taxon_concept.id, id: @taxon_concept_reference.id }, xhr: true
      expect(assigns(:taxon_concept_reference)).not_to be_nil
    end
  end

  describe "XHR PUT update" do
    before do
      @taxon_concept_reference = create(
        :taxon_concept_reference,
        reference_id: @reference.id,
        taxon_concept_id: @taxon_concept.id
      )
    end
    it "renders create when successful" do
      put :update, format: 'js', xhr: true,
        params: {
          taxon_concept_id: @taxon_concept.id,
          id: @taxon_concept_reference.id,
          taxon_concept_reference: {
            reference_attributes:               { citation: "My nice literature" }
          }
        }
      expect(response).to render_template("create")
    end
    it "renders new when not successful" do
      put :update, format: 'js', xhr: true,
        params: {
          taxon_concept_id: @taxon_concept.id,
          id: @taxon_concept_reference.id,
          taxon_concept_reference: {
            reference_attributes: {
              dummy: 'test'
            }
          }
        }
      expect(response).to render_template('new')
    end
  end

  describe "XHR GET 'new'" do
    it "returns http success and renders the new template" do
      get :new, params: { taxon_concept_id: @taxon_concept.id }, xhr: true, format: 'js'
      expect(response).to be_successful
      expect(response).to render_template('new')
    end
  end

  describe "DELETE destroy" do
    let(:taxon_concept_reference) { create(:taxon_concept_reference, taxon_concept_id: @taxon_concept.id, reference_id: @reference.id) }
    it "redirects after delete" do
      delete :destroy, params: { taxon_concept_id: @taxon_concept.id, id: taxon_concept_reference.id }
      expect(response).to redirect_to(
        admin_taxon_concept_taxon_concept_references_url(taxon_concept_reference.taxon_concept)
      )
    end
  end
end
