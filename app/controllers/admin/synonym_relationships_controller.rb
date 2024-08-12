class Admin::SynonymRelationshipsController < Admin::TaxonConceptAssociatedTypesController
  defaults resource_class: TaxonRelationship, collection_name: 'synonym_relationships', instance_name: 'synonym_relationship'
  respond_to :js, only: [ :new, :edit, :create, :update ]
  belongs_to :taxon_concept
  before_action :load_synonym_relationship_type, only: [ :new, :create, :update ]

  def new
    new! do |format|
      @synonym_relationship = TaxonRelationship.new(
        taxon_relationship_type_id: @synonym_relationship_type.id
      )
    end
  end

  def edit
    edit! do |format|
      format.js { render 'new' }
    end
  end
  def create
    params[:taxon_relationship][:taxon_relationship_type_id] =
      @synonym_relationship_type.id
    create! do |success, failure|
      success.js do
        @synonym_relationships = @taxon_concept.synonym_relationships.
          includes(:other_taxon_concept).order('taxon_concepts.full_name')
        render 'create'
      end
      failure.js do
        render 'new'
      end
    end
  end


  def update
    params[:taxon_relationship][:taxon_relationship_type_id] =
      @synonym_relationship_type.id
    update! do |success, failure|
      success.js do
        @synonym_relationships = @taxon_concept.synonym_relationships.
          includes(:other_taxon_concept).order('taxon_concepts.full_name')
        render 'create'
      end
      failure.js do
        render 'new'
      end
    end
  end

  def destroy
    destroy! do |success|
      success.html do
        redirect_to admin_taxon_concept_names_path(@taxon_concept)
      end
    end
  end

  protected

  def load_synonym_relationship_type
    @synonym_relationship_type = TaxonRelationshipType.
      find_by_name(TaxonRelationshipType::HAS_SYNONYM)
  end

  private

  def synonym_relationship_params
    params.require(:taxon_relationship).permit(
      # attributes were in model `attr_accessible`.
      :taxon_concept_id, :other_taxon_concept_id, :taxon_relationship_type_id,
      :created_by_id, :updated_by_id
    )
  end
end
