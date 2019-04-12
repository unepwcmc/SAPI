class SubmissionWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :admin

  def perform(aru_id, submitter_id)
    submitter = User.find(submitter_id)
    begin
      aru = Trade::AnnualReportUpload.find(aru_id)
    rescue ActiveRecord::RecordNotFound => e
      # catch this exception so that retry is not scheduled
      Rails.logger.warn "CITES Report #{aru_id} not found"
      Appsignal.add_exception(e) if defined? Appsignal
      NotificationMailer.changelog_failed(submitter, aru).deliver
      return false
    end

    duplicates = aru.sandbox.check_for_duplicates_in_shipments
    if duplicates.present?
      tempfile = Trade::ChangelogCsvGenerator.call(aru, submitter, duplicates)
      NotificationMailer.duplicates(submitter, aru, tempfile).deliver
      return false
    end

    return false unless aru.sandbox.copy_from_sandbox_to_shipments(submitter)

    tempfile = Trade::ChangelogCsvGenerator.call(aru, submitter)

    upload_on_S3(aru, tempfile)

    records_submitted = aru.sandbox.moved_rows_cnt
    # remove uploaded file
    store_dir = aru.csv_source_file.store_dir
    aru.remove_csv_source_file!
    puts '### removing uploads dir ###'
    puts Rails.root.join('public', store_dir)
    FileUtils.remove_dir(Rails.root.join('public', store_dir), :force => true)

    # clear downloads cache
    DownloadsCache.send(:clear_shipments)

    aru.sandbox.destroy

    # flag as submitted
    aru.update_attributes({
      submitted_at: DateTime.now,
      submitted_by_id: submitter.id,
      number_of_records_submitted: records_submitted
    })

    NotificationMailer.changelog(submitter, aru, tempfile).deliver

    tempfile.delete
  end

  private

  def upload_on_S3(aru, tempfile)
    begin
      s3 = Aws::S3::Resource.new
      filename = "#{Rails.env}/trade/annual_report_upload/#{aru.id}/changelog.csv"
      bucket_name = Rails.application.secrets.aws['bucket_name']
      obj = s3.bucket(bucket_name).object(filename)
      obj.upload_file(tempfile.path)

      aru.update_attributes(aws_storage_path: obj.public_url)
    rescue Aws::S3::Errors::ServiceError => e
      Rails.logger.warn "Something went wrong while uploading #{aru.id} to S3"
      Appsignal.add_exception(e) if defined? Appsignal
    end
  end

end
