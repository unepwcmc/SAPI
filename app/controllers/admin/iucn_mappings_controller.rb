class Admin::IucnMappingsController < Admin::SimpleCrudController

  def index
    @totals = {
      :matching => IucnMapping.filter("MATCHING").count,
      :full_match => IucnMapping.filter("FULL_MATCH").count,
      :name_match => IucnMapping.filter("NAME_MATCH").count,
      :full_synonym_match => IucnMapping.filter("FULL_SYNONYM_MATCH").count,
      :synonym_match => IucnMapping.filter("SYNONYM_NAME_MATCH").count,
      :non_matching => IucnMapping.filter("NON_MATCHING").count,
      :synonyms => IucnMapping.filter('SYNONYMS').count,
      :accepted => IucnMapping.filter('ACCEPTED').count,
      :all => IucnMapping.count

    }
  end

  protected

  def collection
    @iucn_mappings ||= end_of_association_chain.order(:taxon_concept_id).
      page(params[:page]).filter(params[:show] || "ALL").includes(:taxon_concept).
      includes(:accepted_name)
  end
end
