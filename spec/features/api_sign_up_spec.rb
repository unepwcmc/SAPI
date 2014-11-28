require 'spec_helper'

describe "signing up for an API account", :type => :feature do
  before :each do
    @user = FactoryGirl.build(:user)
  end

  it "signs up with valid information" do
    expect{
      sign_up @user
    }.to change{User.count}.by(1)
    expect(page).to have_content 'API User Dashboard'
  end

  it "signs up without accepting terms and conditions" do
    expect{
      sign_up @user, opts = {terms_and_conditions: false}
    }.not_to change{User.count}.by(1)
    expect(page.current_path).to eq api_path
    expect(page).to have_content 'Terms and conditions must be accepted'
  end
end