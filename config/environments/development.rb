SAPI::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  # config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    # Use a memcached instance as a cache store in local development.
    config.cache_store = :mem_cache_store

    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.default_url_options = {
    host: Rails.application.secrets.mailer['host'] || 'http://localhost:3000'
  }

  ActionMailer::Base.default from: Rails.application.secrets.mailer['from']

  # config.action_mailer.delivery_method = :letter_opener
  # Mail server configuration. Development use mailcatcher.
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: Rails.application.secrets.mailer['address'], port: 1025 }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  # config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.js_compressor = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.middleware.use Rack::Cors do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :post, :delete, :put, :options, :head]
    end
  end

  config.ember.variant = :development

  config.eager_load = false
end
