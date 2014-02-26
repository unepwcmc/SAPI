class TradeController < ApplicationController

  private

  def search_params
    (params[:filters] && params[:filters].permit(
      :taxon_concepts_ids,
      :reported_taxon_concepts_ids,
      :appendices,
      :terms_ids,
      :units_ids,
      :purposes_ids,
      :sources_ids,
      :importers_ids,
      :exporters_ids,
      :countries_of_origin_ids,
      :permits_ids,
      :reporter_type,
      :time_range_start,
      :time_range_end,
      :quantity,
      :unit_blank,
      :purpose_blank,
      :source_blank,
      :country_of_origin_blank,
      :permit_blank,
      :report_type,
      :internal,
      :page,
      :csv_separator
    ) || {}).merge({:internal => true, :report_type => :raw})
  end

end
