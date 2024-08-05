class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.dig(:mailer, :from)
  layout 'mailer'
end

