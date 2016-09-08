class Admin::TradeNameRelationshipsController < Admin::TaxonConceptAssociatedTypesController
  defaults :resource_class => TaxonRelationship, :collection_name => 'trade_name_relationships', :instance_name => 'trade_name_relationship'
  respond_to :js, :only => [:new, :edit, :create, :update]
  belongs_to :taxon_concept
  before_filter :load_trade_name_relationship_type, :only => [:new, :create, :update]

  def new
    new! do |format|
      @trade_name_relationship = TaxonRelationship.new(
        :taxon_relationship_type_id => @trade_name_relationship_type.id
      )
    end
  end

  def create
    params[:taxon_relationship][:taxon_relationship_type_id] =
      @trade_name_relationship_type.id
    create! do |success, failure|
      success.js {
        @trade_name_relationships = @taxon_concept.trade_name_relationships.
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
      @trade_name_relationship_type.id
    update! do |success, failure|
      success.js {
        @trade_name_relationships = @taxon_concept.trade_name_relationships.
          includes(:other_taxon_concept).order('taxon_concepts.full_name')
        render 'create'
      }
      failure.js {
        render 'new'
      }
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

  def load_trade_name_relationship_type
    @trade_name_relationship_type = TaxonRelationshipType.
      find_by_name(TaxonRelationshipType::HAS_TRADE_NAME)
  end

end
