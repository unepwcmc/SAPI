class NotificationMailer < ApplicationMailer

  def changelog(user, aru, csv_file)
    @user = user
    @aru = aru
    attachments["changelog_#{@aru.id}.csv"] = File.read(csv_file)
    mail(to: @user.email, subject: 'Changes history log')
  end

  def changelog_failed(user, aru_id)
    @user = user
    @aru = Trade::AnnualReportUpload.find_by(id: aru_id)
    @aru_id = aru_id
    mail(to: @user.email, subject: 'Changes history log - generation failed')
  end

  def duplicates(user, aru, csv_file)
    @user = user
    @aru = aru
    attachments["changelog_with_dulpicates_#{@aru.id}.csv"] = File.read(csv_file)
    mail(to: @user.email, subject: 'Duplicates detected on submission')
  end

  def report_already_submitted(user, aru_id)
    @user = user
    @aru_id = aru_id
    mail(to: @user.email, subject: 'Changes history log - already submitted')
  end

end

