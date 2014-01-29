class Trade::AnnualReportUploadSerializer < ActiveModel::Serializer
  attributes :id, :trading_country_id, :point_of_view, :number_of_rows,
  :is_done, :created_at, :updated_at
  # has_one :created_by
  # has_one :updated_by
  def created_at
    object.created_at.strftime("%d/%m/%y")
  end
  def updated_at
    object.updated_at.strftime("%d/%m/%y")
  end
end
