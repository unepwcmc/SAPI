require 'spec_helper'

describe Admin::CitesSuspensionNotificationsController do
  login_admin

  describe 'index' do
    before(:each) do
      @cites_suspension_notification1 = create_cites_suspension_notification(name: 'B')
      @cites_suspension_notification2 = create_cites_suspension_notification(name: 'A')
    end

    describe 'GET index' do
      it 'assigns @cites_suspension_notifications sorted by name' do
        get :index
        expect(assigns(:cites_suspension_notifications)).to eq(
          [
            @cites_suspension_notification2, @cites_suspension_notification1
          ]
        )
      end
      it 'renders the index template' do
        get :index
        expect(response).to render_template('index')
      end
    end
  end
end
