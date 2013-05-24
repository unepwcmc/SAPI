# == Schema Information
#
# Table name: trade_annual_report_uploads
#
#  id                 :integer          not null, primary key
#  created_by         :integer
#  updated_by         :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  is_done            :boolean          default(FALSE)
#  number_of_rows     :integer
#  csv_source_file    :text
#  trading_country_id :integer          not null
#  point_of_view      :string(255)      default("E"), not null
#

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

  def submit
    sandbox.submit_permits
  end

end
