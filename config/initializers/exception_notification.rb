if Rails.env.production? || Rails.env.staging?
  require 'exception_notification/rails'
  require 'exception_notification/sidekiq'
  require 'yaml'

  ExceptionNotification.configure do |config|
    # Ignore additional exception types.
    # ActiveRecord::RecordNotFound, AbstractController::ActionNotFound and ActionController::RoutingError are already added.
    # config.ignored_exceptions += %w{ActionView::TemplateError CustomError}

    # Adds a condition to decide when an exception must be ignored or not.
    # The ignore_if method can be invoked multiple times to add extra conditions.
    # config.ignore_if do |exception, options|
    #   not Rails.env.production? || Rails.env.staging?
    # end

    # Notifiers =================================================================

    # Email notifier sends notifications by email.
    config.add_notifier :email, {
      :email_prefix => "[SAPI #{Rails.env}] ",
      :sender_address => %{"SAPI Exception Notifier" <no-reply@unep-wcmc.org>},
      :exception_recipients => %w{SpeciesPlusDevs@wcmc.org.uk}
    }

    # Campfire notifier sends notifications to your Campfire room. Requires 'tinder' gem.
    # config.add_notifier :campfire, {
    #   :subdomain => 'my_subdomain',
    #   :token => 'my_token',
    #   :room_name => 'my_room'
    # }

    # HipChat notifier sends notifications to your HipChat room. Requires 'hipchat' gem.
    # config.add_notifier :hipchat, {
    #   :api_token => 'my_token',
    #   :room_name => 'my_room'
    # }

    # Webhook notifier sends notifications over HTTP protocol. Requires 'httparty' gem.
    # config.add_notifier :webhook, {
    #   :url => 'http://example.com:5555/hubot/path',
    #   :http_method => :post
    # }

    secrets = YAML.load(File.open('config/secrets.yml'))

    config.add_notifier :slack, {
      :team => "wcmc",
      :webhook_url => secrets["slack_exception_notification_webhook_url"],
      :channel => "#speciesplus",
      :username => "TheTormentingBotOfSpeciesPlus-#{Rails.env}"
    }
  end
end
