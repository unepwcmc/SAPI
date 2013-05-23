class Trade::ValidationError
  include ActiveModel::SerializerSupport
  attr_accessor :id, :error_message, :error_count

  def initialize(attributes = {})
    @id = attributes[:annual_report_upload_id] + attributes[:validation_rule_id] * 1000 + rand(1000000)
    @error_message = attributes[:error_message]
    @error_count = attributes[:error_count]
  end

end
