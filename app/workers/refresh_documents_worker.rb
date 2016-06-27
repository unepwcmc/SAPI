class RefreshDocumentsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :admin, backtrace: 50, unique: :until_and_while_executing

  def perform
    if DocumentSearch.citations_need_refreshing?
      DocumentSearch.refresh_citations_and_documents
    else
      DocumentSearch.refresh_documents
    end
    DocumentSearch.increment_cache_iterator
  end
end
