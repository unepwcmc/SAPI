class SourceSweeper < ActionController::Caching::Sweeper
  observe Source

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
    ["en", "fr", "es"].each do |lang|
      expire_action(:controller => "api/v1/sources", :action => "index",
                    :locale => lang)
    end
  end
end
