class Trade::ShipmentSecondaryErrorsValidator < ActiveModel::Validator
  def validate(shipment)
    # go through all the secondary error validations
    shipment.warnings = Trade::ValidationRule.where(:is_primary => false).map do |r|
      r.validation_errors_for_shipment(shipment)
    end.compact
    # return true if secondary errors should not prevent from saving
    return true if shipment.ignore_warnings
    false unless shipment.warnings.empty?
  end
end
