require 'spec_helper'

describe Trade::EmberController do
  login_admin

  describe "GET 'start'" do
    it "returns http success" do
      get 'start'
      response.should be_success
    end
  end

end
