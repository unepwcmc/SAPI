class Api::SourcesController < ApplicationController
  respond_to :json
  inherit_resources

  def create
    create! do |success, failure|
      success.json { render :json => @source }
      failure.json { render :json => { :errors => @source.errors } }
    end
  end
end