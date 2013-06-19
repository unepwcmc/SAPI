class CsvColumnHeadersValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    raise(ArgumentError, "A CarrierWave::Uploader::Base object was expected") unless value.kind_of? CarrierWave::Uploader::Base

    require 'csv'
    begin
      CSV.open(value.current_path, "r") do |csv|
          reported_column_headers = csv.first.map(&:downcase)
          required_column_headers = if (record.point_of_view == 'E')
            Trade::SandboxTemplate::EXPORTER_COLUMNS
          else
            Trade::SandboxTemplate::IMPORTER_COLUMNS
          end.map(&:classify).map(&:downcase)
          if !(
            (required_column_headers - reported_column_headers).empty? && 
            (reported_column_headers - required_column_headers).empty?
            )
            record.errors.add(attribute, "file does not have required column headers", {})
          end
      end
    rescue
     record.errors.add(attribute, "file cannot be processed", {})
    end
  end
end
