class EuDecisionObserver < ActiveRecord::Observer

  def after_destroy(eu_decision)
    DownloadsCache.clear_eu_decisions
  end

end