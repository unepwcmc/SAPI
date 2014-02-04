class Trade::ShowAnnualReportUploadSerializer < ActiveModel::Serializer
  root 'annual_report_upload'
  attributes :id, :trading_country_id, :point_of_view, :number_of_rows,
  :file_name, :is_done, :has_primary_errors, :created_at, :updated_at
  has_many :validation_errors
  def file_name
    object.csv_source_file.try(:path) && File.basename(object.csv_source_file.path)
  end
  def has_primary_errors
    !validation_errors.index{ |ve| ve.is_primary }.nil?
  end
  def created_at
    object.created_at.strftime("%d/%m/%y")
  end
  def updated_at
    object.updated_at.strftime("%d/%m/%y")
  end
end
