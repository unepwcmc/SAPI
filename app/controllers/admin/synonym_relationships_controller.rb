class Admin::SynonymRelationshipsController < Admin::SimpleCrudController
  defaults :resource_class => TaxonRelationship, :collection_name => 'synonym_relationships', :instance_name => 'synonym_relationship'
  respond_to :js, :only => [:new, :edit, :create, :update]
  belongs_to :taxon_concept
  before_filter :load_synonym_relationship_type, :only => [:new]

  def new
    @designations = Designation.order(:name)
    @ranks = Rank.order(:taxonomic_position)
    new! do |format|
      @synonym_relationship = TaxonRelationship.new(
        :taxon_relationship_type_id => @synonym_relationship_type.id
      )
      @synonym_relationship.build_other_taxon_concept(
        :designation_id => @taxon_concept.designation_id,
        :rank_id => @taxon_concept.rank_id,
        :name_status => 'S'
      )
      @synonym_relationship.other_taxon_concept.build_taxon_name
    end
  end

  def create
    create! do |success, failure|
      failure.js {
        @designations = Designation.order(:name)
        @ranks = Rank.order(:taxonomic_position)
        render 'new'
      }
    end
  end

  def edit
    @designations = Designation.order(:name)
    @ranks = Rank.order(:taxonomic_position)
    edit! do |format|
      format.js { render 'new' }
    end
  end

  def update
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

  def load_synonym_relationship_type
    @synonym_relationship_type = TaxonRelationshipType.
      find_by_name(TaxonRelationshipType::HAS_SYNONYM)
  end

end

