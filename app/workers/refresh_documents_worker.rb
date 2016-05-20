class RefreshDocumentsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :admin, backtrace: 50, unique: :until_and_while_executing

  def perform
    ActiveRecord::Base.connection.execute('REFRESH MATERIALIZED VIEW api_documents_mview')
    DocumentSearch.increment_cache_iterator
  end
end
