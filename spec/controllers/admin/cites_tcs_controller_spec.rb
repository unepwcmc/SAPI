require 'spec_helper'

describe Admin::CitesTcsController do
  login_admin

  describe 'index' do
    before(:each) do
      @cites_tc1 = create_cites_tc(name: 'Tc1')
      @cites_tc2 = create_cites_tc(name: 'Tc2')
    end

    describe 'GET index' do
      it 'assigns @cites_tcs sorted by name' do
        get :index
        expect(assigns(:cites_tcs)).to eq([ @cites_tc1, @cites_tc2 ])
      end
      it 'renders the index template' do
        get :index
        expect(response).to render_template('index')
      end
    end
  end
end
