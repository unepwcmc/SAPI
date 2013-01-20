class Admin::TaxonConceptsController < Admin::SimpleCrudController
  respond_to :json
  respond_to :js, :only => [:edit]
  inherit_resources

  def index
    @designations = Designation.order(:name)
    @ranks = Rank.order(:taxonomic_position)
    @taxon_concept = TaxonConcept.new
    @taxon_concept.build_taxon_name
    index!
  end

  def edit
    @designations = Designation.order(:name)
    @ranks = Rank.order(:taxonomic_position)
    edit! do |format|
      @languages = Language.order(:name_en)
      @synonym = TaxonConcept.new(:accepted_scientific_name => @taxon_concept.full_name)
      @synonym.build_taxon_name
      format.js { @taxon_concept.is_synonym? ? render('new_synonym') : render('new') }
    end
  end

  def create
    create! do |success, failure|
      @designations = Designation.order(:name)
      @ranks = Rank.order(:taxonomic_position)
      success.js { @taxon_concept.is_synonym? ? render('create_synonym') : render('create') }
      failure.js { @taxon_concept.is_synonym? ? render('new_synonym') : render('new') }
    end
  end

  def update
    update! do |success, failure|
      success.html {
        redirect_to edit_admin_taxon_concept_url(@taxon_concept),
          :notice => 'Operation successful'
      }
      failure.html {
        @languages = Language.order(:name_en)
        render 'edit'
      }
    end
  end

  def autocomplete
    @taxon_concepts = TaxonConcept.where(:name_status => 'A').
      select("data, #{TaxonConcept.table_name}.id, full_name, #{Designation.table_name}.name AS designation_name").
      joins(:designation)
    if params[:scientific_name]
      @taxon_concepts = @taxon_concepts.by_scientific_name(params[:scientific_name])
    end
    if params[:designation_id]
      @taxon_concepts = @taxon_concepts.where(:designation_id => params[:designation_id])
    end
    if params[:rank_id] && params[:name_status] == 'A'
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
        where(:name_status => 'A').
        order(:taxonomic_position).page(params[:page])
    end
end
