class NotificationMailer < ApplicationMailer

  def validation_result(user, aru, validation_report, validation_report_csv_file)
    @user = user
    @aru = aru
    @status = validation_report[:CITESReportResult][:Status]
    @message = validation_report[:CITESReportResult][:Message]
    @has_errors = @aru.validation_report.present?
    if @has_errors
      attachments["validation_report_#{@aru.id}.csv"] = File.read(validation_report_csv_file.path)
u
    end
    mail(to: @user.email, subject: 'CITES Report validation result')
  end

  def changelog(user, aru, csv_file)
    @user = user
    @aru = aru
    attachments["changelog_#{@aru.id}.csv"] = File.read(csv_file)
    mail(to: @user.email, subject: 'Changes history log')
  end

  def changelog_failed(user, aru)
    @user = user
    @aru = aru
    mail(to: @user.email, subject: 'Changes history log - generation failed')
  end

end

