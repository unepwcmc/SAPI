class Admin::TaxonConceptsController < Admin::SimpleCrudController
  inherit_resources

  def index
    @designations = Designation.order(:name)
    @ranks = Rank.order(:name)
    index!
  end

  def create
    @designations = Designation.order(:name)
    @ranks = Rank.order(:name)
    super
  end

  protected
    def collection
      @taxon_concepts ||= end_of_association_chain.
        includes([:rank, :designation, :taxon_name, :parent]).
        order("data->'taxonomic_position'").page(params[:page])
    end
end
