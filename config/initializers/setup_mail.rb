unless Rails.env.test? || Rails.env.development?
  # load mailer_config.yml
  MAILER_CONFIG = YAML.load_file("#{Rails.root}/config/mailer_config.yml")
  env_config = MAILER_CONFIG[Rails.env]
  ActionMailer::Base.smtp_settings = env_config[:smtp_settings]
  ActionMailer::Base.default_url_options = env_config[:default_url_options]
end
