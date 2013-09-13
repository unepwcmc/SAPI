class TimelineSweeper < ActionController::Caching::Sweeper
  observe ListingChange
  observe Annotation

  def after_create(tl)
    expire_cache(tl)
  end

  def after_update(tl)
    expire_cache(tl)
  end

  def after_destroy(tl)
    expire_cache(tl)
  end

  private

  def expire_cache(tl)
    expire_action(:controller => "checklist/timelines", :action => "index")
  end
end
