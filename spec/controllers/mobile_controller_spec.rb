require 'rails_helper'

RSpec.describe MobileController, :type => :controller do

  describe "GET terms_and_conditions" do
    it "returns http success" do
      get :terms_and_conditions
      expect(response).to be_success
    end
  end

  # describe "GET privacy_policy" do
  #   it "returns http success" do
  #     get :privacy_policy
  #     expect(response).to be_success
  #   end
  # end

end
