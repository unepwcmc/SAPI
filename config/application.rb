require_relative 'boot'

require 'zip'
require 'susy'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SAPI
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Since Rails 5, on submit, submission buttons in `form_for` are disabled.
    # However, if errors are thrown and the whole form is not rerendered, then
    # the submit button remains disabled and the form must be manually reloaded
    # by the user.
    config.action_view.automatically_disable_submit_tag = false

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(
      ignore: %w[assets capistrano data files pt scripts tasks]
    )

    # TODO: figure out why we still need the following:
    config.autoload_paths << Rails.root.join('lib/modules')
    config.eager_load_paths << Rails.root.join('lib/modules')

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "London"
    # config.eager_load_paths << Rails.root.join("extras")

    # Active Job
    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.deliver_later_queue_name = 'default'
  end
end
