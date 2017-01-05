require 'aws-sdk'
class ChangesHistoryGeneratorWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :admin

  def perform(aru_id, user_id)
    begin
      aru = Trade::AnnualReportUpload.find(aru_id)
    rescue ActiveRecord::RecordNotFound => e
      # catch this exception so that retry is not scheduled
      message = "CITES Report #{aru_id} not found"
      Rails.logger.warn message
      Appsignal.add_exception(e) if defined? Appsignal
      NotificationMailer.changelog_failed(user, aru).deliver
    end

    user = User.find(user_id)
    tempfile = Trade::ChangelogCsvGenerator.call(aru, user)

    s3 = Aws::S3::Resource.new
    filename = "trade/annual_report_upload/#{aru.id}/changelog.csv"
    bucket_name = Rails.application.secrets.aws['bucket_name']
    obj = s3.bucket(bucket_name).object(filename)
    obj.upload_file(tempfile.path)

    aru.update_attributes(aws_storage_path: obj.public_url)

    NotificationMailer.changelog(user, aru, tempfile).deliver

    tempfile.delete

    # remove sandbox table
    aru.sandbox(true).destroy
  end
end
