class Admin::TaxonConceptsController < Admin::StandardAuthorizationController
  respond_to :json
  layout :determine_layout
  before_action :sanitize_search_params, only: [ :index, :autocomplete ]
  before_action :load_taxonomies, only: [ :index, :edit ]
  before_action :load_ranks, only: [ :index, :edit ]
  before_action :load_tags, only: [ :index, :edit ]
  before_action :split_stringified_ids_lists, only: [ :create, :update ]

  def index
    @taxon_concept = TaxonConcept.new
    @taxon_concepts = TaxonConceptMatcher.new(@search_params).taxon_concepts.
      includes([ :rank, :taxonomy, :taxon_name, :parent ]).
      order('taxon_concepts.taxonomic_position').page(params[:page])
    if @taxon_concepts.count == 1
      redirect_to admin_taxon_concept_names_path(@taxon_concepts.first),
        notice: "Your search returned only one result,
          you have been redirected to the page of #{@taxon_concepts.first.full_name}"
    end
  end

  def edit
    edit! do |format|
      load_search
      format.js { render_new_by_name_status }
    end
  end

  def create
    create! do |success, failure|
      success.js { render('create') }
      failure.js do
        load_taxonomies
        load_ranks
        load_tags
        render_new_by_name_status
      end
    end
  end

  def update
    @taxon_concept = TaxonConcept.find(params[:id])
    rebuild_taxonomy = @taxon_concept.rebuild_taxonomy?(params)
    update! do |success, failure|
      success.js do
        UpdateTaxonomyWorker.perform_async if rebuild_taxonomy
        render 'update'
      end
      failure.js do
        load_taxonomies
        load_ranks
        load_tags
        render_new_by_name_status
      end
      success.html do
        UpdateTaxonomyWorker.perform_async if rebuild_taxonomy
        redirect_to edit_admin_taxon_concept_url(@taxon_concept),
          notice: 'Operation successful'
      end
      failure.html do
        load_taxonomies
        load_ranks
        load_tags
        render 'edit'
      end
    end
  end

  def autocomplete
    @taxon_concepts = TaxonConceptPrefixMatcher.new(@search_params).
      taxon_concepts
    render json: @taxon_concepts.to_json(
      only: [ :id, :taxonomy_name ],
      methods: [ :rank_name, :full_name, :name_status ]
    )
  end

  protected

  # used in create
  def collection
    @taxon_concepts ||= end_of_association_chain.where(name_status: 'A').
      includes([ :rank, :taxonomy, :taxon_name, :parent ]).
      order(:taxonomic_position).page(params[:page])
  end

  def determine_layout
    action_name == 'index' ? 'admin' : 'taxon_concepts'
  end

  def sanitize_search_params
    @search_params = SearchParams.new(
      params[:search_params] ||
      {
        taxonomy: {
          id: Taxonomy.where(name: Taxonomy::CITES_EU).limit(1).
            select(:id).first.id
        }
      }
    )
  end

  def load_tags
    @tags = PresetTag.where(model: PresetTag::TYPES[:TaxonConcept])
  end

  # The frontend will send these as comma-separated string lists of ids
  # We need to coerce them to arrays of integers.
  def split_stringified_ids_lists
    return true if !params[:taxon_concept] || !params[:taxon_concept][:name_status]
    ids_list_key =
      case params[:taxon_concept][:name_status]
      when 'S' then :accepted_names_ids
      when 'T' then :accepted_names_for_trade_name_ids
      when 'H' then :hybrid_parents_ids
      end
    if ids_list_key &&
      params[:taxon_concept].key?(ids_list_key) &&
      (stringified_ids_list = params[:taxon_concept][ids_list_key]) &&
      stringified_ids_list.is_a?(String)
      params[:taxon_concept][ids_list_key] = stringified_ids_list.split(',').map(&:to_i)
    end
  end

  def render_new_by_name_status
    if @taxon_concept.is_synonym?
      render('new_synonym')
    elsif @taxon_concept.is_hybrid?
      render('new_hybrid')
    elsif @taxon_concept.is_trade_name?
      render('new_trade_name')
    elsif @taxon_concept.name_status == 'N'
      render('new_n_name')
    else
      render('new')
    end
  end

  private

  def taxon_concept_params
    params.require(:taxon_concept).permit(
      # attributes were in model `attr_accessible`.
      :parent_id, :taxonomy_id, :rank_id,
      :parent_id, :author_year, :taxon_name_id, :taxonomic_position,
      :legacy_id, :legacy_type, :scientific_name, :name_status,
      :legacy_trade_code,
      :nomenclature_note_en, :nomenclature_note_es, :nomenclature_note_fr,
      :created_by_id, :updated_by_id, :dependents_updated_at, :kew_id,
      hybrid_parents_ids: [], # Coerced to int array by split_stringified_ids_lists
      accepted_names_ids: [], # Coerced to int array by split_stringified_ids_lists
      accepted_names_for_trade_name_ids: [], # Coerced to int array by split_stringified_ids_lists
      tag_list: []
    )
  end
end
