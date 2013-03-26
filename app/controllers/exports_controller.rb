class ExportsController < ApplicationController
  # GET exports/
  #
  def index
    @designations = Designation.order('name')
    @species_listings = SpeciesListing.order('name')
  end

  def download
    case params[:data_type]
      when 'Q'
        result = Quota.export
      when 'S'
        result = Suspension.export
    end
    if result.is_a?(Array)
      send_file result[0], result[1]
    else
      redirect_to exports_path, :notice => "There are no #{params[:data_type] == 'S' ? "suspensions" : "quotas" } to download."
    end
  end
end
