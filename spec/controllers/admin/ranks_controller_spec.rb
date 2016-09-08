require 'spec_helper'

describe Admin::RanksController do
  login_admin

  describe "GET index" do
    it "assigns @ranks sorted by taxonomic position" do
      rank2 = create(:rank, name: Rank::PHYLUM, taxonomic_position: '2')
      rank1 = create(:rank, name: Rank::KINGDOM, taxonomic_position: '1')
      get :index
      assigns(:ranks).should eq([rank1, rank2])
    end
    it "renders the index template" do
      get :index
      response.should render_template("index")
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create, rank: build_attributes(:rank)
      response.should render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create, rank: {}
      response.should render_template("new")
    end
  end

  describe "XHR PUT update" do
    let(:rank) { create(:rank) }
    it "responds with 200 when successful" do
      xhr :put, :update, :format => 'json', :id => rank.id, :rank => { :name => 'ZZ' }
      response.should be_success
    end
    it "responds with json when not successful" do
      xhr :put, :update, :format => 'json', :id => rank.id, :rank => { :name => nil }
      JSON.parse(response.body).should include('errors')
    end
  end

  describe "DELETE destroy" do
    let(:rank) { create(:rank) }
    it "redirects after delete" do
      delete :destroy, :id => rank.id
      response.should redirect_to(admin_ranks_url)
    end
  end

end
