class Admin::CmsMappingsController < Admin::SimpleCrudController
  def index
    @totals = {
      species_plus: TaxonConcept.joins(:taxonomy).
        where(taxonomies: { name: Taxonomy::CMS }).
        where(name_status: 'A').count,
      cms_mapped: CmsMapping.count,
      matches: CmsMapping.index_filter('MATCHES').count,
      missing_species_plus: CmsMapping.index_filter('MISSING_SPECIES_PLUS').count
    }
  end

  protected

  def collection
    @cms_mappings ||= end_of_association_chain.order(
      Arel.sql("taxon_concepts.data->'class_name'")
    ).page(
      params[:page]
    ).includes(:taxon_concept).includes(:accepted_name).index_filter(
      params[:show]
    )
  end
end
