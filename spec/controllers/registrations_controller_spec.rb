require 'spec_helper'

describe RegistrationsController do
  before(:each) do
    @u1 = create(:user,
      password: '11111111', password_confirmation: '11111111'
    )
    @u2 = create(:user)
    @u3 = build(:user)
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  context "when editing own account" do
    it "should update name" do
      sign_in(@u1)
      put :update, params: { id: @u1.id, user: {
        email: @u1.email, name: 'ZZ'
      } }
      expect(response).to redirect_to(admin_root_url)
      expect(@u1.reload.name).to eq('ZZ')
    end
    it "should update password" do
      sign_in(@u1)
      put :update, params: { id: @u1.id, user: {
        email: @u1.email, name: @u1.name,
        password: '22222222', password_confirmation: '22222222',
        current_password: '11111111'
      } }
      expect(response).to redirect_to(admin_root_url)
      expect(@u1.reload.valid_password?('22222222')).to eq(true)
    end
    it "should not update that account if not valid" do
      sign_in(@u1)
      put :update, params: { id: @u1.id, user: {
        email: 'another_email@example.com', name: nil
      } }
      expect(response).to render_template("edit")
      expect(@u1.reload.email).not_to eq('another_email@example.com')
    end
  end

  context "when editing another user's account" do
    it "should not update that account" do
      sign_in(@u1)
      put :update, params: { id: @u2.id, user: {
        email: @u1.email, name: 'ZZ'
      } }
      expect(@u2.reload.name).not_to eq('ZZ')
    end
  end

  context "when signing up" do
    it "should create an account with the role set to api" do
      expect {
        post :create, params: { user: {
          email: @u3.email, name: @u3.name, organisation: 'WCMC',
          password: '22222222', password_confirmation: '22222222'
        } }
      }.to change { User.count }.by(1)
      u = User.last
      expect(u.role).to eq 'api'
    end
  end
end
