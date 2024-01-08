require 'spec_helper'

describe Api::V1::TermsController do
  describe "GET index" do
    before(:each) do
      create(:term)
    end
    it "returns terms" do
      get :index
      expect(response.body).to have_json_size(1).at_path('terms')
    end
  end
end
