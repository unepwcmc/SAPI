class Trade::TaxonConceptTermPairsController < Admin::SimpleCrudController
  inherit_resources
  respond_to :json, :only => [:update]
  #cache_sweeper :unit_sweeper

  def index
    index! do |format|
      format.html { render :template => 'admin/taxon_concept_term_pairs/index' }
    end
  end

  def create
    create! do |success, failure|
      success.js { render :template => 'admin/taxon_concept_term_pairs/create' }
      failure.js { render :template => 'admin/taxon_concept_term_pairs/new' }
    end
  end

  protected

  def collection
    @taxon_concept_term_pairs ||= end_of_association_chain.order('term_id').
      page(params[:page])
  end
end