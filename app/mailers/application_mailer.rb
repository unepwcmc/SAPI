class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.secrets.mailer[:from]
  layout 'mailer'
end

