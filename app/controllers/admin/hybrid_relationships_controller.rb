class Admin::HybridRelationshipsController < Admin::TaxonConceptAssociatedTypesController
  defaults :resource_class => TaxonRelationship, :collection_name => 'hybrid_relationships', :instance_name => 'hybrid_relationship'
  respond_to :js, :only => [:new, :edit, :create, :update]
  belongs_to :taxon_concept
  before_filter :load_hybrid_relationship_type, :only => [:new, :create, :update]

  authorize_resource :class => false

  def new
    new! do |format|
      @hybrid_relationship = TaxonRelationship.new(
        :taxon_relationship_type_id => @hybrid_relationship_type.id
      )
    end
  end

  def create
    params[:taxon_relationship][:taxon_relationship_type_id] =
      @hybrid_relationship_type.id
    create! do |success, failure|
      success.js {
        @hybrid_relationships = @taxon_concept.hybrid_relationships.
          includes(:other_taxon_concept).order('taxon_concepts.full_name')
        render 'create'
      }
      failure.js {
        render 'new'
      }
    end
  end

  def edit
    edit! do |format|
      format.js { render 'new' }
    end
  end

  def update
    params[:taxon_relationship][:taxon_relationship_type_id] =
      @hybrid_relationship_type.id
    update! do |success, failure|
      success.js {
        @hybrid_relationships = @taxon_concept.hybrid_relationships.
          includes(:other_taxon_concept).order('taxon_concepts.full_name')
        render 'create'
      }
      failure.js { render 'new' }
    end
  end

  def destroy
    destroy! do |success|
      success.html {
        redirect_to admin_taxon_concept_names_path(@taxon_concept)
      }
    end
  end

  protected

  def load_hybrid_relationship_type
    @hybrid_relationship_type = TaxonRelationshipType.
      find_by_name(TaxonRelationshipType::HAS_HYBRID)
  end

end
