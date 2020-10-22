class Species::ShowTaxonConceptObserver < ActiveRecord::Observer
  observe :geo_entity, :language

  def after_save(model)
    Rails.cache.delete_matched('*ShowTaxonConceptSerializer*')
  end
end