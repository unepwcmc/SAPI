require 'sidekiq'
require 'sidekiq-status'
require 'sidekiq-unique-jobs'

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware unless Rails.env.test?
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
  config.redis = {
    url: ENV.fetch(
      'SAPI_SIDEKIQ_REDIS_URL',
      Rails.application.credentials.dig(:redis, :url)
    )
  }
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes
    chain.add SidekiqUniqueJobs::Middleware::Server
  end
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware unless Rails.env.test?
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
  config.redis = {
    url: ENV.fetch(
      'SAPI_SIDEKIQ_REDIS_URL',
      Rails.application.credentials.dig(:redis, :url)
    )
  }

  SidekiqUniqueJobs::Server.configure(config)
end
