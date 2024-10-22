require 'spec_helper'

describe Admin::CitesHashAnnotationsController do
  login_admin

  describe 'index' do
    before(:each) do
      cop1 = create_cites_cop(name: 'CoP1')
      cop2 = create_cites_cop(name: 'CoP2')
      @annotation1 = create(
        :annotation,
        parent_symbol: 'CoP2', symbol: '#1', event_id: cop2.id
      )
      @annotation2 = create(
        :annotation,
        parent_symbol: 'CoP1', symbol: '#1', event_id: cop1.id
      )
    end

    describe 'GET index' do
      it 'assigns @annotations sorted by parent_symbol and symbol' do
        get :index
        expect(assigns(:annotations)).to eq([ @annotation2, @annotation1 ])
      end
      it 'renders the index template' do
        get :index
        expect(response).to render_template('index')
      end
    end
  end
end
