class RefreshDocumentsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :admin, backtrace: 50, unique: :until_and_while_executing

  def perform
    DocumentSearch.refresh
  end
end
