class Trade::ShowAnnualReportUploadSerializer < ActiveModel::Serializer
  root 'annual_report_upload'
  attributes :id, :trading_country_id, :point_of_view, :number_of_rows,
  :is_done, :has_primary_errors, :created_at, :updated_at
  # has_one :created_by
  # has_one :updated_by
  has_many :sandbox_shipments
  has_many :validation_errors
  def has_primary_errors
    !validation_errors.index{ |ve| ve.is_primary }.nil?
  end
end
