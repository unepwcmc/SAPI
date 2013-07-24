class Species::ExportsController < ApplicationController

  def download
    case params[:data_type]
      when 'Quotas'
        result = Quota.export params[:filters]
      when 'CitesSuspensions'
        result = CitesSuspension.export params[:filters]
      when 'Listings'
        result = Species::ListingsExportFactory.new(params[:filters]).export
    end
    respond_to do |format|
      format.html {
        if result.is_a?(Array)
          send_file result[0], result[1]
        else 
          redirect_to species_exports_path, :notice => "There are no #{params[:data_type]} to download."
        end
      }
      format.json {
        render :json => {:total => result.is_a?(Array) ? result.count : 0}
      }
    end
  end
end
