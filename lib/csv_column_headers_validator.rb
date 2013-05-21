class CsvColumnHeadersValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    raise(ArgumentError, "A CarrierWave::Uploader::Base object was expected") unless value.kind_of? CarrierWave::Uploader::Base

    require 'csv'
    begin
      CSV.open(value.current_path, "r") do |csv|
          reported_column_headers = csv.first.map(&:downcase)
          valid_column_headers = Trade::SandboxTemplate::COLUMNS_IN_CSV_ORDER.map(&:classify).map(&:downcase)
          required_column_headers = Trade::SandboxTemplate::REQUIRED_COLUMNS.map(&:classify).map(&:downcase)
          reported_column_headers = valid_column_headers & reported_column_headers
          if !(required_column_headers - reported_column_headers).empty?
            record.errors.add(attribute, "file does not have required column headers", {})
          end
      end
    rescue
     record.errors.add(attribute, "file cannot be processed", {})
    end
  end
end
