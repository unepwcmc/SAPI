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
    ["en", "fr", "es"].each do |lang|
      ["1", "2"].each do |set|
        expire_action(:controller => "/checklist/geo_entities", :action => "index",
                     :geo_entity_types_set => set, :locale => lang)
      end
    end

    expire_params = { :controller => "/api/v1/geo_entities", :action => "index"}
    ["en", "fr", "es"].each do |lang|
      ["1", "2", "3", "4"].each do |set|
        expire_action(
          if lang.present?
            expire_params.merge({ :geo_entity_types_set => set, :locale => lang })
          else
            expire_params.merge({ :geo_entity_types_set => set })
          end
        )
      end
    end
  end
end
