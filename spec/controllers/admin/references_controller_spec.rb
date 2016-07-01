require 'spec_helper'

describe Admin::ReferencesController do
  login_admin

  describe "index" do
    before(:each) do
      @reference1 = create(:reference, :citation => 'BB')
      @reference2 = create(:reference, :citation => 'AA')
    end

    describe "GET index" do
      it "assigns @references sorted by citation" do
        get :index
        assigns(:references).should eq([@reference2, @reference1])
      end
      it "renders the index template" do
        get :index
        response.should render_template("index")
      end
    end
    describe "XHR GET index JSON" do
      it "renders json for dropdown" do
        xhr :get, :index, :format => 'json'
        response.body.should have_json_size(2)
        parse_json(response.body, "0/text").should == 'AA'
      end
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create, reference: FactoryGirl.attributes_for(:reference)
      response.should render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create, reference: { :citation => nil }
      response.should render_template("new")
    end
  end

  describe "XHR PUT update JSON" do
    let(:reference) { create(:reference) }
    it "responds with 200 when successful" do
      xhr :put, :update, :format => 'json', :id => reference.id, :reference => { :citation => 'ZZ' }
      response.should be_success
    end
    it "responds with json when not successful" do
      xhr :put, :update, :format => 'json', :id => reference.id, :reference => { :citation => nil }
      JSON.parse(response.body).should include('errors')
    end
  end

  describe "DELETE destroy" do
    let(:reference) { create(:reference) }
    it "redirects after delete" do
      delete :destroy, :id => reference.id
      response.should redirect_to(admin_references_url)
    end
  end

end
