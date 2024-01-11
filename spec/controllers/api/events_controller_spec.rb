require 'spec_helper'

describe Api::V1::EventsController do
  describe "GET index" do
    before(:each) do
      @copX = create(:cites_cop, designation: cites, name: 'CoPX', published_at: '2015-11-01')
      @copY = create(:cites_cop, designation: cites, name: 'CoPY', published_at: '2015-11-02')
      create(:eu_regulation, designation: eu)
    end
    it "returns only E-library events most recent first" do
      get :index
      expect(response.body).to have_json_size(2).at_path('events')
      expect(response.body).to be_json_eql(
        Species::EventSerializer.new(@copY).attributes.to_json
      ).at_path('events/0')
    end
  end
end
