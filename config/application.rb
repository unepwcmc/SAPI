require_relative "boot"

require 'zip'
require 'susy'
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SAPI
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    # Don't set the time zone - it causes issues when converting to columns of
    # type TIMESTAMP WITHOUT TIME ZONE - during BST, dates without time parts
    # first become midnight, then become 2300 the day before.
    #
    # config.time_zone = "London"

    # config.eager_load_paths << Rails.root.join("extras")

    # @see https://gist.github.com/maxivak/381f1e964923f1d469c8d39da8e2522f
    # TODO: Rails 7.1 https://stackoverflow.com/a/77198784/556780
    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths << Rails.root.join("lib", "modules")
    config.eager_load_paths << Rails.root.join("lib", "modules")

    # Active Job
    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.deliver_later_queue_name = 'default'
  end
end
