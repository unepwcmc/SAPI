class Admin::HybridRelationshipsController < Admin::SimpleCrudController
  defaults :resource_class => TaxonRelationship, :collection_name => 'hybrid_relationships', :instance_name => 'hybrid_relationship'
  respond_to :js, :only => [:new, :edit, :create, :update]
  belongs_to :taxon_concept
  before_filter :load_hybrid_relationship_type, :only => [:new, :create, :update]

  def new
    @taxonomies = Taxonomy.order(:name)
    @ranks = Rank.order(:taxonomic_position)
    new! do |format|
      @hybrid_relationship = TaxonRelationship.new(
        :taxon_relationship_type_id => @hybrid_relationship_type.id
      )
      @hybrid_relationship.build_other_taxon_concept(
        :taxonomy_id => @taxon_concept.taxonomy_id,
        :rank_id => @taxon_concept.rank_id,
        :name_status => 'H'
      )
      @hybrid_relationship.other_taxon_concept.build_taxon_name
    end
  end

  def create
    params[:taxon_relationship][:taxon_relationship_type_id] =
      @hybrid_relationship_type.id
    create! do |success, failure|
      failure.js {
        @taxonomies = Taxonomy.order(:name)
        @ranks = Rank.order(:taxonomic_position)
        render 'new'
      }
    end
  end

  def edit
    @taxonomies = Taxonomy.order(:name)
    @ranks = Rank.order(:taxonomic_position)
    edit! do |format|
      format.js { render 'new' }
    end
  end

  def update
    params[:taxon_relationship][:taxon_relationship_type_id] =
      @hybrid_relationship_type.id
    update! do |success, failure|
      success.js { render 'create' }
      failure.js { render 'new' }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html {
        redirect_to edit_admin_taxon_concept_url(params[:taxon_concept_id]),
        :notice => 'Operation successful'
      }
      failure.html {
        redirect_to edit_admin_taxon_concept_url(params[:taxon_concept_id]),
        :notice => 'Operation failed'
      }
    end
  end

  protected

  def load_hybrid_relationship_type
    @hybrid_relationship_type = TaxonRelationshipType.
      find_by_name(TaxonRelationshipType::HAS_HYBRID)
  end

end

