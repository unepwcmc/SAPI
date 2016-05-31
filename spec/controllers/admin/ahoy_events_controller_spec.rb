require 'spec_helper'
require 'securerandom'

describe Admin::AhoyEventsController, :type => :controller do
  login_admin

  describe "index" do

    let!(:ahoy_event1) {
      FactoryGirl.create(:ahoy_event, :name => "Search")
    }
    let!(:ahoy_event2) {
      FactoryGirl.create(:ahoy_event, :name => "Taxon Concept")
    }

    describe "GET index" do
      it "assigns to @ahoy_events sorted by time DESC" do
        events = [ahoy_event1, ahoy_event2]
        get :index
        expect(assigns(:ahoy_events)).to eq(events)
      end
    end
  end
end
