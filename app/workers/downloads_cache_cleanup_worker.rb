class DownloadsCacheCleanupWorker
  include Sidekiq::Worker

  sidekiq_options(
    queue: :admin,
    backtrace: 50,
    # When two identical jobs have been created, discard duplicates, as they
    # will have the same effect. For options see sidekiq-unique-jobs.
    lock: :until_executed
  )

  def perform(type_of_cache)
    DownloadsCache.send(:"clear_#{type_of_cache}")
  end
end
