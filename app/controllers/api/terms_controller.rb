class Api::TermsController < ApplicationController
  respond_to :json
  inherit_resources

  def create
    create! do |success, failure|
      success.json { render :json => @term }
      failure.json { render :json => { :errors => @term.errors } }
    end
  end
end
