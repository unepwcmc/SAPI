unless Rails.env.test? || Rails.env.development?
  # load mailer_config.yml
  MAILER_CONFIG = YAML.load_file("#{Rails.root}/config/mailer_config.yml")
end
