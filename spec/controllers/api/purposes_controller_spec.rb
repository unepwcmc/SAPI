require 'spec_helper'

describe Api::V1::PurposesController do
  describe 'GET index' do
    before(:each) do
      create(:purpose)
    end
    it 'returns purposes' do
      get :index
      expect(response.body).to have_json_size(1).at_path('purposes')
    end
  end
end
