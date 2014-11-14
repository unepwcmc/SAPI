class Species::ExportsController < ApplicationController

  def download
    filters = params[:filters].merge({
      :csv_separator => if params[:filters] && params[:filters][:csv_separator] &&
        params[:filters][:csv_separator].downcase.strip.to_sym == :semicolon
        :semicolon
      else
        :comma
      end
    })
    case params[:data_type]
      when 'Quotas'
        result = Quota.export filters
      when 'CitesSuspensions'
        result = CitesSuspension.export filters
      when 'Listings'
        result = Species::ListingsExportFactory.new(filters).export
      when 'EuDecisions'
        result = Species::EuDecisionsExport.new(filters).export
    end
    respond_to do |format|
      format.html {
        if result.is_a?(Array)
          send_file Pathname.new(result[0]).realpath, result[1]
        else
          redirect_to species_exports_path, :notice => "There are no #{params[:data_type]} to download."
        end
      }
      format.json {
        render :json => {:total => result.is_a?(Array) ? 1 : 0}
      }
    end
  end
end
