class Species::ExportsController < ApplicationController
  require 'sapi/geoip'

  def download
    set_default_separator

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

  def set_default_separator
    if cookies[:default_separator].present?
      default_separator = cookies[:default_separator]
    else
      ip = Sapi::GeoIP.instance.resolve(request.remote_ip)
      separator = DEFAULT_COUNTRY_SEPARATORS[ip[:country].to_sym]
      cookies[:default_separator] = separator
      separator
    end
  end
end
