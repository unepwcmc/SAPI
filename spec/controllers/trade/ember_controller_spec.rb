require 'spec_helper'

describe Trade::EmberController do
  login_admin

  describe "GET 'start'" do
    it "returns http success" do
      get 'start'
      expect(response).to be_successful
    end
  end

end
