class Admin::TaxonConceptsController < Admin::StandardAuthorizationController
  respond_to :json
  layout :determine_layout
  before_filter :sanitize_search_params, :only => [:index, :autocomplete]
  before_filter :load_tags, :only => [:index, :edit, :create]

  def index
    @taxonomies = Taxonomy.order(:name)
    @ranks = Rank.order(:taxonomic_position)
    @taxon_concept = TaxonConcept.new(name_status: 'A')
    @taxon_concept.build_taxon_name
    @synonym = TaxonConcept.new(name_status: 'S')
    @synonym.build_taxon_name
    @hybrid = TaxonConcept.new(name_status: 'H')
    @hybrid.build_taxon_name
    @n_name = TaxonConcept.new(name_status: 'N')
    @n_name.build_taxon_name
    @taxon_concepts = TaxonConceptMatcher.new(@search_params).taxon_concepts.
      includes([:rank, :taxonomy, :taxon_name, :parent]).
      order("taxon_concepts.taxonomic_position").page(params[:page])
    if @taxon_concepts.count == 1
      redirect_to admin_taxon_concept_names_path(@taxon_concepts.first),
        :notice => "Your search returned only one result,
          you have been redirected to the page of #{@taxon_concepts.first.full_name}"
    end
  end

  def edit
    @ranks = Rank.order(:taxonomic_position)
    edit! do |format|
      load_search
      format.js { render 'new' }
    end
  end

  def create
    create! do |success, failure|
      @taxonomies = Taxonomy.order(:name)
      @ranks = Rank.order(:taxonomic_position)
      success.js { render('create') }
      failure.js {
        if @taxon_concept.is_synonym?
          @synonym = @taxon_concept
          render('new_synonym')
        elsif @taxon_concept.is_hybrid?
          @hybrid = @taxon_concept
          render('new_hybrid')
        elsif @taxon_concept.name_status == 'N'
          @n_name = @taxon_concept
          render('new_n_name')
        else
          render('new')
        end
      }
    end
  end

  def update
    @taxon_concept = TaxonConcept.find(params[:id])
    taxa_ids = sanitize_update_params
    rebuild_taxonomy = @taxon_concept.rebuild_taxonomy?(params)
    update! do |success, failure|
      success.js {
        @taxon_concept.rebuild_relationships(taxa_ids) if taxa_ids.present?
        UpdateTaxonomyWorker.perform_async if rebuild_taxonomy
        render 'update'
      }
      failure.js {
        @taxonomies = Taxonomy.order(:name)
        @ranks = Rank.order(:taxonomic_position)
        load_tags
        render 'new'
      }
      success.html {
        @taxon_concept.rebuild_relationships(taxa_ids) if taxa_ids.present?
        UpdateTaxonomyWorker.perform_async if rebuild_taxonomy
        redirect_to edit_admin_taxon_concept_url(@taxon_concept),
          :notice => 'Operation successful'
      }
      failure.html {
        @taxonomies = Taxonomy.order(:name)
        @ranks = Rank.order(:taxonomic_position)
        load_tags
        render 'edit'
      }
    end
  end

  def autocomplete
    @taxon_concepts = TaxonConceptPrefixMatcher.new(@search_params).
     taxon_concepts
    render :json => @taxon_concepts.to_json(
      :only => [:id, :taxonomy_name],
      :methods => [:rank_name, :full_name, :name_status]
    )
  end

  protected
    # used in create
    def collection
      @taxon_concepts ||= end_of_association_chain.where(:name_status => 'A').
        includes([:rank, :taxonomy, :taxon_name, :parent]).
        order(:taxonomic_position).page(params[:page])
    end

    def determine_layout
      action_name == 'index' ? 'admin' : 'taxon_concepts'
    end

    def sanitize_search_params
      @search_params = SearchParams.new(
        params[:search_params] ||
        { :taxonomy => { :id => Taxonomy.
          where(:name => Taxonomy::CITES_EU).limit(1).select(:id).first.id }
        })
    end

    def sanitize_update_params
      name_status = params[:taxon_concept] ? params[:taxon_concept][:name_status] : ''
      taxa_ids = []
      if params[:taxon_concept]
        name_ids =
          case name_status
          when 'S' then :accepted_name_ids
          when 'T' then :accepted_names_for_trade_name_ids
          when 'H' then :hybrid_parent_ids
          else return []
          end
          taxa_ids =
            params[:taxon_concept].delete(name_ids).first.split(',').map(&:to_i)
      end
      taxa_ids
    end

    def load_tags
      @tags = PresetTag.where(:model => PresetTag::TYPES[:TaxonConcept])
    end
end
