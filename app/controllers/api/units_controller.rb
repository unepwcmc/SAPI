class Api::UnitsController < ApplicationController
  respond_to :json
  inherit_resources

  def create
    create! do |success, failure|
      success.json { render :json => @unit }
      failure.json { render :json => { :errors => @unit.errors } }
    end
  end
end