require 'spec_helper'

describe Trade::ValidationRulesController do
  login_admin

  describe "GET index" do
    it "should return success" do
      get :index, format: :json
      response.should be_success
    end
  end
end
