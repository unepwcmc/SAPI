Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # TODO: Only support Rails version < 5
  # GEM `protected_attributes` settings (https://github.com/rails/protected_attributes#errors)
  config.active_record.mass_assignment_sanitizer = :strict

  # Custom cache settings
  config.cache_store = :memory_store, { size: 64.megabytes }

  # Custom ember settings
  config.ember.variant = :development

  # Custom email settings
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: Rails.application.secrets.mailer['address'], port: 1025 }
  config.action_mailer.default_url_options = {
    host: Rails.application.secrets.mailer['host'] || 'http://localhost:3000'
  }
  ActionMailer::Base.default from: Rails.application.secrets.mailer['from']

  # CORS settings
  # TODO: Rails 5 should build-in, need change this part when upgrade.
  config.middleware.use Rack::Cors do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :post, :delete, :put, :options, :head]
    end
  end
end
