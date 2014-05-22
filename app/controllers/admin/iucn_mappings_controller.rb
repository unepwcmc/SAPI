class Admin::IucnMappingsController < Admin::SimpleCrudController

  def index
    @totals = {
      :with_match => Admin::IucnMapping.where('iucn_taxon_id IS NOT NULL').count,
      :without_match => Admin::IucnMapping.where(:iucn_taxon_id => nil).count,
      :all => Admin::IucnMapping.count
    }
  end

  protected

  def collection
    @iucn_mappings ||= end_of_association_chain.order(:taxon_concept_id).
      page(params[:page]).filter(params[:show]||0)
  end
end
