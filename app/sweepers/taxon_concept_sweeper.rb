class TaxonConceptSweeper < ActionController::Caching::Sweeper
  observe TaxonConcept

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
    expire_action(:controller => "taxon_concepts", :action => "index")
  end
end
