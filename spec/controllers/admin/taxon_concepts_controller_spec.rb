require 'spec_helper'

describe Admin::TaxonConceptsController do
  login_admin

  describe "GET index" do
    before(:each) do
      @taxon = create_cites_eu_species(
        :taxon_name => create(:taxon_name, :scientific_name => 'indefinitus'),
        :taxonomic_position => '1.1.2',
        :parent => create_cites_eu_genus(
          :taxon_name => create(:taxon_name, :scientific_name => 'Foobarus'),
          :taxonomic_position => '1.1.1'
        )
      )
    end
    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
      expect(response).to render_template("layouts/admin")
    end
    it "redirects if 1 result" do
      get :index, search_params: {
        taxonomy: { id: cites_eu.id }, scientific_name: 'Foobarus i'
      }
      expect(response).to redirect_to(admin_taxon_concept_names_path(@taxon))
    end
    it "assigns taxa in taxonomic order" do
      get :index, search_params: {
        taxonomy: { id: cites_eu.id }, scientific_name: 'Foobarus'
      }
      expect(assigns(:taxon_concepts)).to eq([@taxon.parent, @taxon])
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create,
        taxon_concept: {
          name_status: 'A',
          taxonomy_id: cites_eu.id,
          rank_id: create(:rank, name: Rank::GENUS),
          scientific_name: 'Canis',
          parent_id: create_cites_eu_family
        }
      expect(response).to render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create, taxon_concept: { dummy: 'test'}
      expect(response).to render_template("new")
    end
    it "renders new_synonym when not successful S" do
      xhr :post, :create, taxon_concept: { name_status: 'S' }
      expect(response).to render_template("new_synonym")
    end
    it "renders new_hybrid when not successful H" do
      xhr :post, :create, taxon_concept: { name_status: 'H' }
      expect(response).to render_template("new_hybrid")
    end
    it "renders new_synonym when not successful N" do
      xhr :post, :create, taxon_concept: { name_status: 'N' }
      expect(response).to render_template("new_n_name")
    end
  end

  describe "XHR PUT update" do
    let(:taxon_concept) { create(:taxon_concept) }
    context "when JSON" do
      it "responds with 200 when successful" do
        xhr :put, :update, :format => 'json', :id => taxon_concept.id,
          :taxon_concept => { dummy: 'test' }
        expect(response).to be_success
      end
      it "responds with json error when not successful" do
        xhr :put, :update, :format => 'json', :id => taxon_concept.id,
          :taxon_concept => { :taxonomy_id => nil }
        expect(JSON.parse(response.body)).to include('errors')
      end
    end
    context "when HTML" do
      it "redirects to edit when successful" do
        put :update, :id => taxon_concept.id,
          :taxon_concept => { dummy: 'test' }
        expect(response).to redirect_to(edit_admin_taxon_concept_url(taxon_concept))
      end
      it "renders edit when not successful" do
        put :update, :id => taxon_concept.id,
          :taxon_concept => { :taxonomy_id => nil }
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    let(:taxon_concept) { create(:taxon_concept) }
    it "redirects after delete" do
      delete :destroy, :id => taxon_concept.id
      expect(response).to redirect_to(admin_taxon_concepts_url)
    end
  end

  describe "DELETE destroy doesn't work for non managers" do
    login_contributor
    let(:taxon_concept) { create(:taxon_concept) }

    it "redirects to admin root path and doesn't delete" do
      delete :destroy, :id => taxon_concept.id
      expect(response).to redirect_to(admin_root_path)
      expect(TaxonConcept.where(:id => taxon_concept.id).size).to eq(1)
    end
  end

  describe "when E-library Viewer" do
    login_elibrary_viewer
    let(:taxon_concept) { create(:taxon_concept) }

    it "redirects to root path" do
      get :index
      expect(response).to redirect_to(root_path)
    end

    it "redirects to root path and doesn't delete" do
      delete :destroy, :id => taxon_concept.id
      expect(response).to redirect_to(root_path)
      expect(TaxonConcept.where(:id => taxon_concept.id).size).to eq(1)
    end
  end

  describe "XHR GET JSON autocomplete" do
    let!(:taxon_concept) {
      create_cites_eu_genus(
        :taxon_name => create(:taxon_name, :scientific_name => 'AAA')
      )
    }
    it "returns properly formatted json" do
      xhr :get, :autocomplete, :format => 'json',
        :search_params => { :scientific_name => 'AAA' }
      expect(response.body).to have_json_size(1)
      expect(parse_json(response.body, "0/full_name")).to eq('Aaa')
    end
  end

end
