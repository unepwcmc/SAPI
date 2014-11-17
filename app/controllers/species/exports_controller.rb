class Species::ExportsController < ApplicationController
  require 'sapi/geoip'

  def download
    set_default_separator

    @filters = params[:filters].merge({
      :csv_separator => cookies['speciesplus.csv_separator']
    })
    case params[:data_type]
      when 'Quotas'
        result = Quota.export @filters
      when 'CitesSuspensions'
        result = CitesSuspension.export @filters
      when 'Listings'
        result = Species::ListingsExportFactory.new(@filters).export
      when 'EuDecisions'
        result = Species::EuDecisionsExport.new(@filters).export
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
    separator_params = params[:filters][:csv_separator]
    separator_cookie = cookies['speciesplus.csv_separator']

    if separator_params.present?
      cookies.permanent['speciesplus.csv_separator'] = separator_params
    elsif separator_cookie.present?
      return
    else
      ip = request.remote_ip
      if ip == '127.0.0.1' || nil
        separator = ','
      else
        ip_data = Sapi::GeoIP.instance.resolve(ip)
        separator = DEFAULT_COUNTRY_SEPARATORS[ip_data[:country].to_sym] || ','
      end
      cookies.permanent['speciesplus.csv_separator'] = separator
    end
  end
end
