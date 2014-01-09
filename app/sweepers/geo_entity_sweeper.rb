class GeoEntitySweeper < ActionController::Caching::Sweeper
  observe GeoEntity

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
    expire_action(:controller => "/checklist/geo_entities", :action => "index")
    expire_action(:controller => "/api/v1/geo_entities", :action => "index",
                 :geo_entity_types_set => "4", :locale => "en")
    expire_action(:controller => "/api/v1/geo_entities", :action => "index",
                 :geo_entity_types_set => "4")
  end
end
