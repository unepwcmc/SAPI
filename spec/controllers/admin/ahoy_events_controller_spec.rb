require 'spec_helper'
require 'securerandom'

describe Admin::AhoyEventsController do
  login_admin

  describe 'index' do
    let!(:ahoy_event1) do
      create(:ahoy_event, name: 'Search')
    end
    let!(:ahoy_event2) do
      create(:ahoy_event, name: 'Taxon Concept')
    end

    describe 'GET index' do
      it 'assigns to @ahoy_events sorted by time DESC' do
        events = [ ahoy_event1, ahoy_event2 ]
        get :index
        expect(assigns(:ahoy_events)).to eq(events)
      end
    end
  end
end
