class Admin::IucnMappingsController < Admin::SimpleCrudController

  def index
    @totals = {
      :matching => IucnMapping.index_filter("MATCHING").count,
      :full_match => IucnMapping.index_filter("FULL_MATCH").count,
      :name_match => IucnMapping.index_filter("NAME_MATCH").count,
      :full_synonym_match => IucnMapping.index_filter("FULL_SYNONYM_MATCH").count,
      :synonym_match => IucnMapping.index_filter("SYNONYM_NAME_MATCH").count,
      :non_matching => IucnMapping.index_filter("NON_MATCHING").count,
      :synonyms => IucnMapping.index_filter('SYNONYMS').count,
      :accepted => IucnMapping.index_filter('ACCEPTED').count,
      :all => IucnMapping.count

    }
  end

  protected

  def collection
    @iucn_mappings ||= end_of_association_chain.order(:taxon_concept_id).
      page(params[:page]).index_filter(params[:show] || "ALL").includes(:taxon_concept).
      includes(:accepted_name)
  end
end
