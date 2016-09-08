class Admin::CmsMappingsController < Admin::SimpleCrudController

  def index
    @totals = {
      :species_plus => TaxonConcept.joins(:taxonomy).
        where(:taxonomies => { :name => Taxonomy::CMS }).
        where(:name_status => 'A').count,
      :cms_mapped => CmsMapping.all.count,
      :matches => CmsMapping.filter('MATCHES').count,
      :missing_species_plus => CmsMapping.filter('MISSING_SPECIES_PLUS').count
    }
  end

  protected

  def collection
    @cms_mappings ||= end_of_association_chain.
      order("taxon_concepts.data->'class_name'").
      page(params[:page]).includes(:taxon_concept).
      includes(:accepted_name).filter(params[:show])
  end
end
