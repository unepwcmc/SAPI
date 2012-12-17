class Api::LanguagesController < ApplicationController
  respond_to :json
  inherit_resources

  def create
    create! do |success, failure|
      success.json { render :json => @language }
      failure.json { render :json => { :errors => @language.errors } }
    end
  end
end
