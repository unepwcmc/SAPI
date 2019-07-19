class Api::SpeciesListingsController < ApplicationController
  respond_to :json
  inherit_resources

  DESIGNATION = %w[CITES CMS EU].freeze

  def index
    appendix = unless (trade_plus_params.present? && sanitize_params)
                  SpeciesListing.all
                else
                  desig_id = Designation.find_by_name(trade_plus_params[:designation].upcase).id
                  SpeciesListing.where(designation_id: desig_id)
                end
    render :json => appendix
  end

  private

  def trade_plus_params
    params.permit(:designation)
  end

  def sanitize_params
    return true if trade_plus_params.empty?
    DESIGNATION.include?(trade_plus_params[:designation].upcase)
  end

end
