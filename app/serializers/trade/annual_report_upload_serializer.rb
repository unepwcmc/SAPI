class Trade::AnnualReportUploadSerializer < ActiveModel::Serializer
  attributes :id, :original_filename, :number_of_rows, :is_done, :created_at,
    :updated_at
  # has_one :created_by
  # has_one :updated_by
  has_many :sandbox_shipments
end
