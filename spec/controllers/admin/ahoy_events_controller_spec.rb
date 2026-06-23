require 'spec_helper'
require 'securerandom'

describe Admin::AhoyEventsController do
  login_admin

  describe 'index' do
    let!(:ahoy_event_older) do
      create(:ahoy_event, name: 'Search', time: 3.days.ago)
    end

    let!(:ahoy_event_newer) do
      create(:ahoy_event, name: 'Taxon Concept', time: 2.days.ago)
    end

    describe 'GET index' do
      it 'assigns to @ahoy_events sorted by time DESC' do
        events = [ ahoy_event_newer, ahoy_event_older ]

        get :index
        expect(assigns(:ahoy_events)).to eq(events)
      end
    end
  end
end
