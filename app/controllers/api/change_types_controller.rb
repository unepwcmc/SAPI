class Api::ChangeTypesController < ApplicationController
  respond_to :json
  inherit_resources

  def create
    create! do |success, failure|
      success.json { render :json => @change_type }
      failure.json { render :json => { :errors => @change_type.errors } }
    end
  end
end
