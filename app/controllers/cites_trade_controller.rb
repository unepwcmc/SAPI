class CitesTradeController < ApplicationController

  private

  def search_params
    (params[:filters] || params).permit(
      :time_range_start,
      :time_range_end,
      :report_type,
      :selection_taxon,
      :page,
      :csv_separator,
      taxon_concepts_ids: [],
      appendices: [],
      terms_ids: [],
      units_ids: [],
      purposes_ids: [],
      sources_ids: [],
      importers_ids: [],
      exporters_ids: [],
      countries_of_origin_ids: []
    ).merge({
      # if taxon search comes from the genus selector, search descendants
      :taxon_with_descendants =>
        (params[:filters] && params[:filters][:selection_taxon] == 'taxonomic_cascade'),
      :report_type =>
        if params[:filters] && params[:filters][:report_type] &&
          Trade::ShipmentsExportFactory.public_report_types.include?(
            report_type = params[:filters][:report_type].downcase.strip.to_sym
          )
          report_type
        else
          :comptab
        end,
      :csv_separator =>
        if params[:filters] && params[:filters][:csv_separator] &&
          params[:filters][:csv_separator].downcase.strip.to_sym == :semicolon
          :semicolon
        else
          :comma
        end
    })
  end

end
