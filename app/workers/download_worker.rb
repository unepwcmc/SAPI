class DownloadWorker
  include Sidekiq::Worker

  def perform(type, format, user_id, params)
  end
end
