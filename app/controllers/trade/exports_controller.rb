class Trade::ExportsController < ApplicationController
  respond_to :json

  def download
    
    search = Trade::ShipmentsExportFactory.new(params[:filters])

    respond_to do |format|
      format.html {
        result = search.export
        if result.is_a?(Array)
          send_file result[0], result[1]
          log_download request, params
        else
          head :no_content
        end
      }
      format.json {
        render :json => { :total => search.total_cnt }
      }
    end
  end

  private

  def get_field_list param, model
    model.find_all_by_id(param.map(&:to_i)).map { |r| r.code }.join ','
  end

  def log_download request, params
    unless params['origin'] == 'public' then return end

    data = {}
    filters = params['filters']
    data["user_ip"] = request.ip
    data["report_type"] = filters['report_type']
    data["year_from"] = filters['time_range_start']
    data["year_to"] = filters['time_range_end']
    data["taxon"] = filters['selection_taxon']
    data["term"] = get_field_list filters['terms_ids'], Term

#    {"ssname"=>"ct_60847153", "ssID"=>"CT8F02EFDC",  "exporters_ids"=>[""], "importers_ids"=>[""], "sources_ids"=>[""], "purposes_ids"=>[""], "terms_ids"=>[""],  "taxon_concepts_ids"=>[""], "reset"=>"", "report_type"=>"comptab"}
#    :taxon,
#   :appendix, :importer, :exporter, :origin, :term, :unit, :source, :purpose
    
    w = TradeDataDownload.new(data)
    w.save

  end

end