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
  track_who_does_it
  attr_accessible :csv_source_file, :trading_country_id, :point_of_view
  mount_uploader :csv_source_file, Trade::CsvSourceFileUploader
  belongs_to :trading_country, :class_name => GeoEntity, :foreign_key => :trading_country_id
  validates :csv_source_file, :csv_column_headers => true, :on => :create

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
    return [] if is_done
    run_primary_validations
    if (@validation_errors.count == 0)
      run_secondary_validations
    end
    @validation_errors
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
    run_primary_validations
    unless @validation_errors.count == 0
      self.errors[:base] << "Submit failed, primary validation errors present."
      return false
    end
    return false unless sandbox.copy_from_sandbox_to_shipments
    #remove uploaded file
    store_dir = csv_source_file.store_dir
    remove_csv_source_file!
    puts '### removing uploads dir ###'
    puts Rails.root.join('public', store_dir)
    FileUtils.remove_dir(Rails.root.join('public', store_dir), :force => true)

    #remove sandbox table
    sandbox.destroy

    #clear downloads cache
    DownloadsCache.clear_shipments

    #flag as submitted
    update_attribute(:is_done, true)
  end

  private
  # Expects a relation object
  def run_validations(validation_rules)
    validation_errors = []
    validation_rules.order(:run_order).each do |vr|
      validation_errors << vr.validation_errors(self)
    end
    validation_errors.flatten
  end

  def run_primary_validations
    @validation_errors = run_validations(
      Trade::ValidationRule.where(:is_primary => true)
    )
  end

  def run_secondary_validations
    @validation_errors += run_validations(
      Trade::ValidationRule.where(:is_primary => false)
    )
  end

end
