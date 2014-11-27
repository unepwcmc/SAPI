require 'spec_helper'

describe "signing up for an API account", :type => :feature do
  before :each do
    @user = FactoryGirl.build(:user)
  end

  it "signs up with valid information" do
    expect{
      sign_up @user
    }.to change{User.count}.by(1)
    expect(page).to have_content 'API Dashboard'
  end

  it "signs up without accepting terms and conditions" do
    expect{
      sign_up @user, {terms_and_conditions: false}
    }.not_to change{User.count}.by(1)
    expect(page).to have_content 'Sign Up'
  end
end