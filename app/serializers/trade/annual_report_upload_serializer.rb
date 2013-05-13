class Trade::AnnualReportUploadSerializer < ActiveModel::Serializer
  attributes :id, :original_filename, :length
end
