class Admin::IucnMappingsController < Admin::SimpleCrudController

  def index
    @totals = {
      :matching => Admin::IucnMapping.filter("MATCHING").count,
      :full_match => Admin::IucnMapping.filter("FULL_MATCH").count,
      :name_match => Admin::IucnMapping.filter("NAME_MATCH").count,
      :full_synonym_match => Admin::IucnMapping.filter("FULL_SYNONYM_MATCH").count,
      :synonym_match => Admin::IucnMapping.filter("SYNONYM_MATCH").count,
      :non_matching => Admin::IucnMapping.filter("NON_MATCHING").count,
      :all => Admin::IucnMapping.count,

    }
  end

  protected

  def collection
    @iucn_mappings ||= end_of_association_chain.order(:taxon_concept_id).
      page(params[:page]).filter(params[:show]||"ALL").includes(:taxon_concept).
      includes(:synonym)
  end
end
