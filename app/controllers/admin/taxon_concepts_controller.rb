class Admin::TaxonConceptsController < Admin::SimpleCrudController
  respond_to :json
  layout :determine_layout
  before_filter :sanitize_search_params, :only => [:index, :autocomplete]

  def index
    @taxonomies = Taxonomy.order(:name)
    @ranks = Rank.order(:taxonomic_position)
    @taxon_concept = TaxonConcept.new(:name_status => 'A')
    @taxon_concept.build_taxon_name
    @synonym = TaxonConcept.new(:name_status => 'S')
    @synonym.build_taxon_name
    @hybrid = TaxonConcept.new(:name_status => 'H')
    @hybrid.build_taxon_name
    @tags = ActsAsTaggableOn::Tag.all
    @taxon_concepts = TaxonConceptMatcher.new(@search_params).taxon_concepts.
      includes([:rank, :taxonomy, :taxon_name, :parent]).
      order(:taxonomic_position).page(params[:page])
  end

  def edit
    @taxonomies = Taxonomy.order(:name)
    @ranks = Rank.order(:taxonomic_position)
    @tags = ActsAsTaggableOn::Tag.all
    edit! do |format|
      @languages = Language.order(:name_en)
      format.js { render 'new' }
    end
  end

  def create
    create! do |success, failure|
      @taxonomies = Taxonomy.order(:name)
      @ranks = Rank.order(:taxonomic_position)
      @tags = ActsAsTaggableOn::Tag.all
      success.js { render('create') }
      failure.js {
        if @taxon_concept.is_synonym?
          @synonym = @taxon_concept
          render('new_synonym')
        else
          render('new')
        end
      }
    end
  end

  def update
    update! do |success, failure|
      success.js {
        render 'update'
      }
      failure.js {
        @taxonomies = Taxonomy.order(:name)
        @ranks = Rank.order(:taxonomic_position)
        render 'new'
      }
      success.html {
        redirect_to edit_admin_taxon_concept_url(@taxon_concept),
          :notice => 'Operation successful'
      }
      failure.html {
        @taxonomies = Taxonomy.order(:name)
        @ranks = Rank.order(:taxonomic_position)
        render 'edit'
      }
    end
  end

  def autocomplete
    @taxon_concepts = TaxonConceptPrefixMatcher.new(@search_params).
     taxon_concepts
    render :json => @taxon_concepts.to_json(
      :only => [:id, :taxonomy_name],
      :methods => [:rank_name, :full_name]
    )
  end

  protected

    def determine_layout
      action_name == 'index' ? 'admin' : 'taxon_concepts'
    end

    def sanitize_search_params
      @search_params = SearchParams.new(params[:search_params] || {})
    end

end
