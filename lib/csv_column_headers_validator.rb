class CsvColumnHeadersValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    raise(ArgumentError, "A CarrierWave::Uploader::Base object was expected") unless value.kind_of? CarrierWave::Uploader::Base

    require 'csv'
    CSV.open(value.current_path, "r") do |csv|
        column_headers = csv.first.map(&:downcase)
        if column_headers != options[:is]
          record.errors.add(attribute, "wrong column headers there", {})
        end
    end
  end

end
