# == Schema Information
#
# Table name: trade_annual_report_uploads
#
#  id                          :integer          not null, primary key
#  auto_reminder_sent_at       :datetime
#  aws_storage_path            :string(255)
#  created_by                  :integer
#  csv_source_file             :text
#  deleted_at                  :datetime
#  epix_created_at             :datetime
#  epix_submitted_at           :datetime
#  epix_updated_at             :datetime
#  force_submit                :boolean          default(FALSE)
#  is_from_web_service         :boolean          default(FALSE)
#  number_of_records_submitted :integer
#  number_of_rows              :integer
#  point_of_view               :string(255)      default("E"), not null
#  sandbox_transferred_at      :datetime
#  submitted_at                :datetime
#  updated_by                  :integer
#  validated_at                :datetime
#  validation_report           :jsonb
#  created_at                  :datetime
#  updated_at                  :datetime
#  created_by_id               :integer
#  deleted_by_id               :integer
#  epix_created_by_id          :integer
#  epix_submitted_by_id        :integer
#  epix_updated_by_id          :integer
#  sandbox_transferred_by_id   :integer
#  submitted_by_id             :integer
#  trading_country_id          :integer          not null
#  updated_by_id               :integer
#
# Indexes
#
#  index_trade_annual_report_uploads_on_created_by          (created_by)
#  index_trade_annual_report_uploads_on_created_by_id       (created_by_id)
#  index_trade_annual_report_uploads_on_trading_country_id  (trading_country_id)
#  index_trade_annual_report_uploads_on_updated_by          (updated_by)
#  index_trade_annual_report_uploads_on_updated_by_id       (updated_by_id)
#
# Foreign Keys
#
#  trade_annual_report_uploads_created_by_fk          (created_by => users.id)
#  trade_annual_report_uploads_created_by_id_fk       (created_by_id => users.id)
#  trade_annual_report_uploads_trading_country_id_fk  (trading_country_id => geo_entities.id)
#  trade_annual_report_uploads_updated_by_fk          (updated_by => users.id)
#  trade_annual_report_uploads_updated_by_id_fk       (updated_by_id => users.id)
#

require 'csv_column_headers_validator'
class Trade::AnnualReportUpload < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection
  include TrackWhoDoesIt

  # Suppose use in controller, but controller using strong parameters...
  # attr_accessible :csv_source_file, :trading_country_id, :point_of_view,
  #                 :submitted_at, :submitted_by_id, :number_of_rows,
  #                 :number_of_records_submitted, :aws_storage_path

  mount_uploader :csv_source_file, Trade::CsvSourceFileUploader
  belongs_to :trading_country, class_name: 'GeoEntity'
  validates :csv_source_file, csv_column_headers: true, on: :create

  scope :created_by_sapi, -> {
    where(epix_created_by_id: nil)
  }

  after_create :copy_to_sandbox
  before_destroy do
    success = sandbox && sandbox.destroy
    throw(:abort) unless success
  end

  def copy_to_sandbox
    sandbox.copy

    update_attribute(:number_of_rows, sandbox_shipments.size)
  end

  # object that represents the particular sandbox table linked to this annual
  # report upload
  def sandbox(tmp = false)
    return nil if submitted_at.present? && !tmp

    @sandbox ||= Trade::Sandbox.new(self)
  end

  def sandbox_shipments
    return [] if submitted_at.present?

    sandbox.shipments
  end

  def validation_errors
    return [] if submitted_at.present?

    run_primary_validations
    if @validation_errors.count == 0
      run_secondary_validations
    end
    @validation_errors
  end

  def to_jq_upload
    if valid?
      {
        'id' => self.id,
        'name' => self[:csv_source_file],
        'size' => csv_source_file.size,
        'url' => csv_source_file.url
      }
    else
      {
        'name' => self[:csv_source_file],
        'error' => 'Upload failed on: ' + errors[:csv_source_file].join('; ')
      }
    end
  end

  def submit(submitter)
    run_primary_validations
    unless @validation_errors.count == 0
      self.errors[:base] << 'Submit failed, primary validation errors present.'
      return false
    end
    return false unless sandbox.copy_from_sandbox_to_shipments(submitter)

    records_submitted = sandbox.moved_rows_cnt
    # remove uploaded file
    store_dir = csv_source_file.store_dir
    remove_csv_source_file!
    Rails.logger.debug '### removing uploads dir ###'
    Rails.logger.debug Rails.public_path.join(store_dir)
    FileUtils.remove_dir(Rails.public_path.join(store_dir), force: true)

    # clear downloads cache
    DownloadsCacheCleanupWorker.perform_async('shipments')

    # flag as submitted
    update(
      submitted_at: DateTime.now,
      submitted_by_id: submitter.id,
      number_of_records_submitted: records_submitted
    )

    # This has been temporarily disabled as originally part of EPIX
    # ChangesHistoryGeneratorWorker.perform_async(self.id, submitter.id)
  end

  def reported_by_exporter?
    point_of_view == 'E'
  end

  def is_submitted?
    submitted_at.present?
  end

private

  # Expects a relation object
  def run_validations(validation_rules)
    validation_errors = []
    validation_rules.order(:run_order).each do |vr|
      vr.refresh_errors_if_needed(self)
      validation_errors << vr.validation_errors_for_aru(self)
    end
    validation_errors.flatten
  end

  def run_primary_validations
    @validation_errors = run_validations(
      Trade::ValidationRule.where(is_primary: true)
    )
  end

  def run_secondary_validations
    @validation_errors += run_validations(
      Trade::ValidationRule.where(is_primary: false)
    )
  end
end
