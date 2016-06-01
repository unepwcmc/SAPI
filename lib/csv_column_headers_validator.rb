class CsvColumnHeadersValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    raise(ArgumentError, "A CarrierWave::Uploader::Base object was expected") unless value.kind_of? CarrierWave::Uploader::Base

    require 'csv'
    begin
      CSV.open(value.current_path, "r") do |csv|
        reported_column_headers = csv.first.map(&:downcase)
        required_column_headers =
          if (record.point_of_view == 'E')
            Trade::SandboxTemplate::CSV_EXPORTER_COLUMNS
          else
            Trade::SandboxTemplate::CSV_IMPORTER_COLUMNS
          end.map(&:classify).map(&:downcase)
        missing_columns = required_column_headers - reported_column_headers
        excess_columns = reported_column_headers - required_column_headers
        if !(missing_columns.empty? && excess_columns.empty?)
          error_msg = "invalid column headers: "
          unless missing_columns.empty?
            error_msg += 'missing: ' + missing_columns.join(', ') + '; '
          end
          unless excess_columns.empty?
            error_msg += 'excess: ' + excess_columns.join(', ') + '; '
          end
          record.errors.add(attribute, error_msg, {})
        end
      end
    rescue => e
      Rails.logger.error e.inspect
      record.errors.add(attribute, "file cannot be processed", {})
    end
  end
end
