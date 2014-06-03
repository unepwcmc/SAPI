require 'sidekiq'
require 'sidekiq-status'

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware unless Rails.env.test?
  end
  config.redis = { :url => 'redis://127.0.0.1:6379/0', :namespace => 'SAPI' }
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware
  end
  config.redis = { :url => 'redis://127.0.0.1:6379/0', :namespace => 'SAPI' }
end
