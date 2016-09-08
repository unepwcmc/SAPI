class Species::ExportsController < ApplicationController
  before_filter :ensure_data_type_and_filters, :only => [:download]

  def download
    set_csv_separator

    @filters = params[:filters].merge({
      :csv_separator => cookies['speciesplus.csv_separator'].try(:to_sym)
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
          # this was added in order to prevent download managers from
          # failing when chunked_transfer_encoding is set in nginx (1.8.1)
          file_path = Pathname.new(result[0]).realpath
          response.headers['Content-Length'] = File.size(file_path).to_s
          send_file file_path, result[1]
        else
          redirect_to species_exports_path, :notice => "There are no #{params[:data_type]} to download."
        end
      }
      format.json {
        render :json => { :total => result.is_a?(Array) ? 1 : 0 }
      }
    end
  end

  private

  def set_csv_separator
    separator_params = params[:filters][:csv_separator]
    separator_cookie = cookies['speciesplus.csv_separator']
    if separator_params.present?
      cookies.permanent['speciesplus.csv_separator'] = separator_params
    elsif separator_cookie.present?
      return
    else
      ip = request.remote_ip
      separator = Sapi::GeoIP.instance.default_separator(ip)
      cookies.permanent['speciesplus.csv_separator'] = separator
    end
  end

  def ensure_data_type_and_filters
    unless params[:data_type] && params[:filters]
      render(:nothing => true, :status => :unprocessable_entity) && (return false)
    end
  end
end
