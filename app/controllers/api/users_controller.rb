class Api::UsersController < ApplicationController
  respond_to :json
  inherit_resources

  def create
    create! do |success, failure|
      success.json { render :json => @user }
      failure.json { render :json => { :errors => @user.errors } }
    end
  end
end
