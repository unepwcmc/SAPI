class Api::PurposesController < ApplicationController
  respond_to :json
  inherit_resources

  def create
    create! do |success, failure|
      success.json { render :json => @purpose }
      failure.json { render :json => { :errors => @purpose.errors } }
    end
  end
end