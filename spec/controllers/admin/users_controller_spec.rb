require 'spec_helper'

describe Admin::UsersController do
  login_admin

  describe 'index' do
    describe 'GET index' do
      it 'renders the index template' do
        get :index
        expect(response).to render_template('index')
      end
    end
  end

  describe 'XHR POST create' do
    it 'renders create when successful' do
      post :create, params: { user: FactoryBot.attributes_for(:user) }, xhr: true
      expect(response).to render_template('create')
    end
    it 'renders new when not successful' do
      post :create, params: { user: { name: nil } }, xhr: true
      expect(response).to render_template('new')
    end
  end

  describe 'XHR GET edit' do
    let(:user) { create(:user) }
    it 'renders the edit template' do
      get :edit, params: { id: user.id }, xhr: true
      expect(response).to render_template('new')
    end
    it 'assigns the hybrid_relationship variable' do
      get :edit, params: { id: user.id }, xhr: true
      expect(assigns(:user)).not_to be_nil
    end
  end

  describe 'XHR PUT update JS' do
    let(:user) { create(:user) }
    it 'responds with 200 when successful' do
      put :update, format: 'js', params: { id: user.id, user: { name: 'ZZ' } }, xhr: true
      expect(response).to be_successful
      expect(response).to render_template('create')
    end
    it 'responds with template new when not successful' do
      put :update, format: 'js', params: { id: user.id, user: { name: nil } }, xhr: true
      expect(response).to render_template('new')
    end
  end

  describe 'DELETE destroy' do
    let(:user) { create(:user) }
    it 'redirects after delete' do
      delete :destroy, params: { id: user.id }
      expect(response).to redirect_to(admin_users_url)
    end
  end
end
