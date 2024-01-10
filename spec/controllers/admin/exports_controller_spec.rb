require 'spec_helper'

describe Admin::ExportsController do
  login_admin

  describe "GET index" do
    it "renders the index template" do
      get :index
      response.should render_template("index")
      response.should render_template("layouts/admin")
    end
  end
  describe "GET download with data_type=Names" do
    after(:each) do
      DownloadsCache.clear_taxon_concepts
    end
    context "all" do
      it "returns taxon concepts names file" do
        create(:taxon_concept)
        expect_any_instance_of(Species::TaxonConceptsNamesExport).to receive(:public_file_name).and_return('taxon_concepts_names.csv')
        get :download, :data_type => "Names"
        expect(response.content_type).to eq("text/csv")
        expect(response.headers["Content-Disposition"]).to eq("attachment; filename=\"taxon_concepts_names.csv\"")
      end
      it "redirects when no results" do
        get :download, :data_type => "Names"
        response.should redirect_to(admin_exports_path)
      end
    end
    context "CITES_EU" do
      it "returns CITES_EU taxon concepts names file" do
        create_cites_eu_species
        expect_any_instance_of(Species::TaxonConceptsNamesExport).to receive(:public_file_name).and_return('taxon_concepts_names.csv')
        get :download, :data_type => "Names", :filters => { :taxonomy => 'CITES_EU' }
        expect(response.content_type).to eq("text/csv")
        expect(response.headers["Content-Disposition"]).to eq("attachment; filename=\"taxon_concepts_names.csv\"")
      end
      it "redirects when no results" do
        get :download, :data_type => "Names", :filters => { :taxonomy => 'CITES_EU' }
        response.should redirect_to(admin_exports_path)
      end
    end
    context "CMS" do
      it "returns CMS taxon concepts names file" do
        create_cms_species
        expect_any_instance_of(Species::TaxonConceptsNamesExport).to receive(:public_file_name).and_return('taxon_concepts_names.csv')
        get :download, :data_type => "Names", :filters => { :taxonomy => 'CMS' }
        expect(response.content_type).to eq("text/csv")
        expect(response.headers["Content-Disposition"]).to eq("attachment; filename=\"taxon_concepts_names.csv\"")
      end
      it "redirects when no results" do
        get :download, :data_type => "Names", :filters => { :taxonomy => 'CMS' }
        response.should redirect_to(admin_exports_path)
      end
    end
  end
  describe "GET download with data_type=Distributions" do
    after(:each) do
      DownloadsCache.clear_distributions
    end
    context "all" do
      it "returns taxon concepts distributions file" do
        tc = create(:taxon_concept)
        create(:distribution, :taxon_concept_id => tc.id)
        expect_any_instance_of(Species::TaxonConceptsDistributionsExport).to receive(:public_file_name).and_return('taxon_concepts_distributions.csv')
        get :download, :data_type => "Distributions"
        expect(response.content_type).to eq("text/csv")
        expect(response.headers["Content-Disposition"]).to eq("attachment; filename=\"taxon_concepts_distributions.csv\"")
      end
      it "redirects when no results" do
        get :download, :data_type => "Distributions"
        response.should redirect_to(admin_exports_path)
      end
    end
    context "CITES_EU" do
      it "returns CITES_EU taxon concepts distributions file" do
        tc = create_cites_eu_species
        create(:distribution, :taxon_concept_id => tc.id)
        expect_any_instance_of(Species::TaxonConceptsDistributionsExport).to receive(:public_file_name).and_return('taxon_concepts_distributions.csv')
        get :download, :data_type => "Distributions", :filters => { :taxonomy => 'CITES_EU' }
        expect(response.content_type).to eq("text/csv")
        expect(response.headers["Content-Disposition"]).to eq("attachment; filename=\"taxon_concepts_distributions.csv\"")
      end
      it "redirects when no results" do
        get :download, :data_type => "Distributions", :filters => { :taxonomy => 'CITES_EU' }
        response.should redirect_to(admin_exports_path)
      end
    end
    context "CMS" do
      it "returns CMS taxon concepts distributions file" do
        tc = create_cms_species
        create(:distribution, :taxon_concept_id => tc.id)
        expect_any_instance_of(Species::TaxonConceptsDistributionsExport).to receive(:public_file_name).and_return('taxon_concepts_distributions.csv')
        get :download, :data_type => "Distributions", :filters => { :taxonomy => 'CMS' }
        expect(response.content_type).to eq("text/csv")
        expect(response.headers["Content-Disposition"]).to eq("attachment; filename=\"taxon_concepts_distributions.csv\"")
      end
      it "redirects when no results" do
        get :download, :data_type => "Distributions", :filters => { :taxonomy => 'CMS' }
        response.should redirect_to(admin_exports_path)
      end
    end
  end
end
