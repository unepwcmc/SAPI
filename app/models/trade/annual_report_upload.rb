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
  include ActiveModel::ForbiddenAttributesProtection
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

  def update_attributes_and_sandbox(attributes)
    Trade::AnnualReportUpload.transaction do
      update_sandbox(attributes.delete(:sandbox_shipments))
      update_attributes(attributes)
    end
  end

  def update_sandbox(shipments)
    return true if is_done
    sandbox.shipments= shipments
  end

  def validation_errors
    return [] if is_done
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

  #TODO: this method needs error checking
  def submit
    sandbox.submit_permits
    sandbox.submit_shipments
    #TODO probably would be good to wrap in transaction
    # and return number of inserted shipments?

    # none of the below should happen if there are rows that
    # we were unable to move over

    #remove uploaded file
    store_dir = csv_source_file.store_dir
    remove_csv_source_file!
    puts '### removing uploads dir ###'
    puts Rails.root.join('public', store_dir)
    FileUtils.remove_dir(Rails.root.join('public', store_dir), :force => true)

    #remove sandbox table
    sandbox.destroy

    #flag as submitted
    update_attribute(:is_done, true)
  end

end
