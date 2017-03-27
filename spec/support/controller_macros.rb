module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in @user || FactoryGirl.create(:user, role: User::MANAGER)
    end
  end

  def login_contributor
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in FactoryGirl.create(:user, role: User::CONTRIBUTOR)
    end
  end

  def login_elibrary_viewer
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in FactoryGirl.create(:user, role: User::ELIBRARY_USER)
    end
  end

  def login_api_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in FactoryGirl.create(:user, role: User::API_USER)
    end
  end

  def login_secretariat_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in FactoryGirl.create(:user, role: User::SECRETARIAT)
    end
  end
end
