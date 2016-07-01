require 'spec_helper'

RSpec.describe "Home page", type: :request do
  it "redirects Data Manager to admin root path" do
    user = create(:user, role: User::MANAGER)
    post "/users/sign_in", user: { email: user.email, password: user.password }
    assert_redirected_to admin_root_path
  end
  it "redirects Data Contributor to admin root path" do
    user = create(:user, role: User::CONTRIBUTOR)
    post "/users/sign_in", user: { email: user.email, password: user.password }
    assert_redirected_to admin_root_path
  end
  it "redirects E-library Viewer to public root path" do
    user = create(:user, role: User::ELIBRARY_USER)
    post "/users/sign_in", user: { email: user.email, password: user.password }
    assert_redirected_to root_path
  end
  it "redirects API User to public root path" do
    user = create(:user, role: User::API_USER)
    post "/users/sign_in", user: { email: user.email, password: user.password }
    assert_redirected_to root_path
  end
end
