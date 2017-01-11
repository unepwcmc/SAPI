class NotificationMailer < ApplicationMailer

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

  def duplicates(user, aru, csv_file)
    @user = user
    @aru = aru
    attachments["changelog_with_dulpicates_#{@aru.id}.csv"] = File.read(csv_file)
    mail(to: @user.email, subject: 'Duplicates detected on submission')
  end

end

