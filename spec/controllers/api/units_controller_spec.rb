require 'spec_helper'

describe Api::V1::UnitsController do
  describe "GET index" do
    before(:each) do
      create(:unit)
    end
    it "returns units" do
      get :index
      response.body.should have_json_size(1).at_path('units')
    end
  end
end
