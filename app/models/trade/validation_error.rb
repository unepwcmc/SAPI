class Trade::ValidationError
  include ActiveModel::SerializerSupport
  attr_reader :id, :error_message, :error_count, :sandbox_shipment_ids,
    :is_primary

  def initialize(attributes = {})
    @id = attributes[:annual_report_upload_id] +
      attributes[:validation_rule_id] * 1000 + rand(1000000)
    @error_message = attributes[:error_message]
    @error_count = attributes[:error_count]
    @sandbox_shipment_ids = attributes[:matching_records_ids]
    @is_primary = attributes[:is_primary]
  end

end
