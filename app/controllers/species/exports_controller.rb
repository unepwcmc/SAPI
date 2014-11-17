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
    #Merge this all into one cookie
    #If cookie exists (set by user BEFORE they click download), use that
    #if not set then we'll get the ip and set a cookie
    if cookies['speciesplus.csv_separator'].present?
      separator = cookies['speciesplus.csv_separator']
    else
      ip = request.remote_ip
      if ip == '127.0.0.1' || nil
        separator = ','
      else
        ip_data = Sapi::GeoIP.instance.resolve(ip)
        separator = DEFAULT_COUNTRY_SEPARATORS[ip_data[:country].to_sym]
      end
      cookies.permanent['speciesplus.csv_separator'] = separator

      separator # Not sure if we need this, depends on if reading from cookie or method
    end
  end
end
