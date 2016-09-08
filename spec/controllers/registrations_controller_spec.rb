require 'spec_helper'

describe RegistrationsController do
  before(:each) do
    @u1 = create(:user,
      :password => '11111111', :password_confirmation => '11111111'
    )
    @u2 = create(:user)
    @u3 = build(:user)
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  context "when editing own account" do
    it "should update name" do
      sign_in(@u1)
      put :update, :id => @u1.id, :user => {
        :email => @u1.email, :name => 'ZZ'
      }
      response.should redirect_to(admin_root_url)
    end
    it "should update password" do
      sign_in(@u1)
      put :update, :id => @u1.id, :user => {
        :email => @u1.email, :name => @u1.name,
        :password => '22222222', :password_confirmation => '22222222',
        :current_password => '11111111'
      }
      response.should redirect_to(admin_root_url)
    end
    it "should not update that account if not valid" do
      sign_in(@u1)
      put :update, :id => @u1.id, :user => {
        :email => @u1.email, :name => nil
      }
      response.should render_template("edit")
    end
  end

  context "when editing another user's account" do
    it "should not update that account" do
      sign_in(@u1)
      put :update, :id => @u2.id, :user => {
        :email => @u1.email, :name => 'ZZ'
      }
      @u2.reload.name.should_not == 'ZZ'
    end
  end

  context "when signing up" do
    it "should create an account with the role set to api" do
      expect {
        post :create, :user => {
          :email => @u3.email, :name => @u3.name, :organisation => 'WCMC',
          :password => '22222222', :password_confirmation => '22222222'
        }
      }.to change { User.count }.by(1)
      u = User.last
      expect(u.role).to eq 'api'
    end
  end
end
