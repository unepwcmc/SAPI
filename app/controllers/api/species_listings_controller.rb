class Api::SpeciesListingsController < ApplicationController
  respond_to :json
  inherit_resources

  def index
    designations = Designation.where(sanitized_params)
    listings = SpeciesListing.where(designation_id: designations)
    render :json => listings
  end

  private

  def trade_plus_params
    params.permit(:designation)
  end

  def sanitized_params
    return nil if trade_plus_params.empty? || !trade_plus_params[:designation].present?

    user_designations = trade_plus_params[:designation].split(',').map(&:upcase)
    designations = Designation.pluck(:name).map(&:upcase)
    {name: user_designations & designations }
  end

end
