require 'spec_helper'
require 'securerandom'

describe Admin::AhoyVisitsController, :type => :controller do
  login_admin

  describe "index" do
    let!(:ahoy_visit1) { FactoryGirl.create(:ahoy_visit, :browser => "Safari", :device_type => "Desktop") }
    let!(:ahoy_visit2) { FactoryGirl.create(:ahoy_visit, :browser => "Firefox", :device_type => "Desktop") }

    describe "GET index" do
      it "assigns to @ahoy_events sorted by time DESC" do
        visits = [ahoy_visit1, ahoy_visit2]
        get :index
        expect(assigns(:ahoy_visits)).to eq(visits)
      end
    end
  end
end
