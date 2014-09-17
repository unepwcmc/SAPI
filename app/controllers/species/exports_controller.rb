class Species::ExportsController < ApplicationController

  def download
    csv_separator, csv_separator_char = case params[:filters][:csv_separator]
      when 'semicolon' then ['semicolon', ';']
      else ['comma', ',']
    end
    filters = params[:filters].merge({
      csv_separator: csv_separator, csv_separator_char: csv_separator_char
    })
    case params[:data_type]
      when 'Quotas'
        result = Quota.export filters
      when 'CitesSuspensions'
        result = CitesSuspension.export filters
      when 'Listings'
        result = Species::ListingsExportFactory.new(filters).export
      when 'EuDecisions'
        result = EuDecision.export filters
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
