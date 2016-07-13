class EuDecisionObserver < ActiveRecord::Observer

  def after_destroy(eu_decision)
    DownloadsCacheCleanupWorker.perform_async(:eu_decisions)
  end

end
