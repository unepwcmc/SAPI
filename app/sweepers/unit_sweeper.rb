class UnitSweeper < ActionController::Caching::Sweeper
  observe Unit

  def after_create(tc)
    expire_cache(tc)
  end

  def after_update(tc)
    expire_cache(tc)
  end

  def after_destroy(tc)
    expire_cache(tc)
  end

  private

  def expire_cache(tc)
    expire_action(:controller => "api/v1/units", :action => "index")
  end
end
