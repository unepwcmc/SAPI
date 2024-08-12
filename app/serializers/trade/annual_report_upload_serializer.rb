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
# Foreign Keys
#
#  trade_annual_report_uploads_created_by_fk          (created_by => users.id)
#  trade_annual_report_uploads_created_by_id_fk       (created_by_id => users.id)
#  trade_annual_report_uploads_trading_country_id_fk  (trading_country_id => geo_entities.id)
#  trade_annual_report_uploads_updated_by_fk          (updated_by => users.id)
#  trade_annual_report_uploads_updated_by_id_fk       (updated_by_id => users.id)
#
class Trade::AnnualReportUploadSerializer < ActiveModel::Serializer
  attributes :id, :trading_country_id, :point_of_view, :number_of_rows,
  :file_name, :created_at, :updated_at, :created_by, :updated_by

  def file_name
    object.csv_source_file.try(:path) && File.basename(object.csv_source_file.path)
  end

  def created_at
    object.created_at && object.created_at.strftime('%d/%m/%y')
  end

  def updated_at
    object.updated_at && object.updated_at.strftime('%d/%m/%y')
  end

  def created_by
    object.creator && object.creator.name
  end

  def updated_by
    object.updater && object.updater.name
  end
end
