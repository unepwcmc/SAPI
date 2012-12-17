class Api::SpeciesListingsController < ApplicationController
  respond_to :json
  inherit_resources

  def create
    create! do |success, failure|
      success.json { render :json => @species_listing }
      failure.json { render :json => { :errors => @species_listing.errors } }
    end
  end
end
