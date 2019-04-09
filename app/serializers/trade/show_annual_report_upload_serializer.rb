class Trade::ShowAnnualReportUploadSerializer < ActiveModel::Serializer
  root 'annual_report_upload'
  attributes :id, :trading_country_id, :point_of_view, :number_of_rows,
  :file_name, :has_primary_errors, :created_at, :updated_at,
  :created_by, :updated_by
  has_many :validation_errors, :ignored_validation_errors

  def validation_errors
    object.validation_errors.reject do |ve|
      ve.is_ignored
    end.sort_by(&:error_message)
  end

  def ignored_validation_errors
    object.validation_errors.select do |ve|
      ve.is_ignored
    end.sort_by(&:error_message)
  end

  def file_name
    object.csv_source_file.try(:path) && File.basename(object.csv_source_file.path)
  end

  def has_primary_errors
    !validation_errors.index { |ve| ve.is_primary }.nil?
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
    object.creator && object.updater.name
  end
end
