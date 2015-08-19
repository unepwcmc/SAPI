require 'spec_helper'

describe Api::V1::DocumentTagsController do
  describe "GET index" do
    before(:each) do
      create(:proposal_outcome)
    end
    it "returns document tags" do
      get :index
      response.body.should have_json_size(1).at_path('document_tags')
    end
  end
end
