class Trade::TradeDataDownloadsExport < Species::CsvCopyExport

  def query
    Trade::TradeDataDownload.order(:created_at)
  end

  private

  def resource_name
    'trade_download_stats'
  end

  def sql_columns
    [
      :user_ip,
      :report_type,
      :year_from,
      :year_to,
      :taxon,
      :appendix,
      :importer,
      :exporter,
      :origin,
      :term,
      :unit,
      :source,
      :purpose,
      :number_of_rows,
      :city,
      :country,
      :organization,
      :created_at
    ]
  end

  def csv_column_headers
    sql_columns.map(&:to_s).map(&:humanize)
  end

end
