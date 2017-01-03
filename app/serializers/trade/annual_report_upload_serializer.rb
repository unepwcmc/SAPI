class Trade::AnnualReportUploadSerializer < ActiveModel::Serializer
  attributes :id, :trading_country_id, :point_of_view, :number_of_rows,
  :file_name, :created_at, :updated_at, :created_by, :updated_by

  def file_name
    object.csv_source_file.try(:path) && File.basename(object.csv_source_file.path)
  end

  def created_at
    object.created_at && object.created_at.strftime("%d/%m/%y")
  end

  def updated_at
    object.updated_at && object.updated_at.strftime("%d/%m/%y")
  end

  def created_by
    object.creator && object.creator.name
  end

  def updated_by
    object.updater && object.updater.name
  end
end
