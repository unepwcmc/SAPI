require 'spec_helper'

describe Api::V1::SourcesController do
  describe "GET index" do
    before(:each) do
      create(:source)
    end
    it "returns sources" do
      get :index
      response.body.should have_json_size(1).at_path('sources')
    end
  end
end
