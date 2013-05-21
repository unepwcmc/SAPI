class CsvColumnHeadersValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    raise(ArgumentError, "A CarrierWave::Uploader::Base object was expected") unless value.kind_of? CarrierWave::Uploader::Base

    require 'csv'
    begin
      CSV.open(value.current_path, "r") do |csv|
          column_headers = csv.first.map(&:downcase)
          required_column_headers = Trade::SandboxTemplate.column_names
          if column_headers != required_column_headers
            record.errors.add(attribute, "file has invalid column headers", {})
          end
      end
    rescue
      record.errors.add(attribute, "file cannot be processed", {})
    end
  end
end
