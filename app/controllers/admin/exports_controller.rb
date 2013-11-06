class Admin::ExportsController < ApplicationController

  def index; end

  def download
    result = Species::TaxonConceptsNamesExport.new(params[:filters]).export
    respond_to do |format|
      format.html {
        if result.is_a?(Array)
          send_file result[0], result[1]
        else
          redirect_to admin_exports_path, :notice => "There are no #{params[:data_type]} to download."
        end
      }
      format.json {
        render :json => {:total => result.is_a?(Array) ? 1 : 0}
      }
    end
  end

end
