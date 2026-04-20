require 'spec_helper'

describe Trade::ValidationRulesController do
  login_admin

  describe 'GET index' do
    it 'returns success' do
      get :index, format: :json
      expect(response).to be_successful
    end
  end
end
