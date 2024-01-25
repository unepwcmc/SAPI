require_relative 'boot'

require 'rails/all'
require "susy"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SAPI
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # @see https://gist.github.com/maxivak/381f1e964923f1d469c8d39da8e2522f
    # TODO: Rails 7.1 https://stackoverflow.com/a/77198784/556780
    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths << Rails.root.join("lib", "modules")
    config.eager_load_paths << Rails.root.join("lib", "modules")

    # Activate observers that should always be running.
    config.active_record.observers = :destroy_observer, :annotation_observer,
      :cites_cop_observer, :cites_suspension_notification_observer,
      :eu_regulation_observer, :eu_suspension_regulation_observer,
      :eu_event_observer, :"trade/annual_report_upload_observer",
      :listing_change_observer, :taxon_concept_observer,
      :cites_suspension_observer, :quota_observer, :eu_decision_observer,
      :"trade/shipment_observer", :"trade/trade_data_download_observer",
      :change_observer, :document_observer, :nomenclature_change_observer,
      :geo_entity_observer

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    config.i18n.available_locales = %i[en es fr]
    config.i18n.default_locale = :en
  end
end
