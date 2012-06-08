#require 'development_mail_interceptor'

ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
  :address => "email-filter.unep-wcmc.org",
  :port => 25,
  :domain => "unep-wcmc.org",
}

#Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
