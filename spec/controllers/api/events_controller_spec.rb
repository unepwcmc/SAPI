require 'spec_helper'

describe Api::V1::EventsController do
  describe "GET index" do
    before(:each) do
      create(:cites_cop, designation: cites)
      create(:eu_regulation, designation: eu)
    end
    it "returns E-library events" do
      get :index
      response.body.should have_json_size(1).at_path('events')
    end
  end
end
