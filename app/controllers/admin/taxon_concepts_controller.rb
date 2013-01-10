class Admin::TaxonConceptsController < Admin::SimpleCrudController
  respond_to :json
  inherit_resources

  def index
    @designations = Designation.order(:name)
    @ranks = Rank.order(:taxonomic_position)
    index!
  end

  def create
    @designations = Designation.order(:name)
    @ranks = Rank.order(:taxonomic_position)
    super
  end

  def autocomplete
    @taxon_concepts = TaxonConcept.
      select("data, #{TaxonConcept.table_name}.id, #{Designation.table_name}.name AS designation_name").
      joins(:designation)
    if params[:scientific_name]
      @taxon_concepts = @taxon_concepts.by_scientific_name(params[:scientific_name])
    end
    if params[:designation_id]
      @taxon_concepts = @taxon_concepts.where(:designation_id => params[:designation_id])
    end
    if params[:rank_id]
      rank = Rank.find(params[:rank_id])
      @taxon_concepts = @taxon_concepts.at_parent_ranks(rank)
    end
    render :json => @taxon_concepts.to_json(
      :only => [:id, :designation_name],
      :methods => [:rank_name, :full_name]
    )
  end

  protected
    def collection
      @taxon_concepts ||= end_of_association_chain.
        includes([:rank, :designation, :taxon_name, :parent]).
        where("data->'cites_name_status' = 'A'" ).
        order(:taxonomic_position).page(params[:page])
    end
end
