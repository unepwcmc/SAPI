require 'csv_column_headers_validator'
class Trade::AnnualReportUpload < ActiveRecord::Base
  attr_accessible :number_of_rows, :csv_source_file, :trading_country_id, :point_of_view
  mount_uploader :csv_source_file, Trade::CsvSourceFileUploader
  belongs_to :trading_country, :class_name => GeoEntity, :foreign_key => :trading_country_id
  validates :csv_source_file, :csv_column_headers => true

  def copy_to_sandbox
    sandbox.copy
    update_attribute(:number_of_rows, sandbox_shipments.size)
  end

  # object that represents the particular sandbox table linked to this annual
  # report upload
  def sandbox
    return nil if is_done
    @sandbox ||= Trade::Sandbox.new(self)
  end

  def sandbox_shipments
    return [] if is_done
    sandbox.shipments
  end

  def validation_errors
      @validation_errors = []
      validation_rules = Trade::ValidationRule.order(:run_order)
      validation_rules.each do |vr|
        @validation_errors << vr.validation_errors(self)
      end
      @validation_errors.flatten
  end

  def to_jq_upload
    if valid?
    {
      "id" => self.id,
      "name" => read_attribute(:csv_source_file),
      "size" => csv_source_file.size,
      "url" => csv_source_file.url
    }
    else
      {
        "name" => read_attribute(:csv_source_file),
        'error' => "Upload failed on: " + errors[:csv_source_file].join('; ')
      }
    end
  end
end
