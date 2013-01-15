class Admin::TaxonRelationshipsController < Admin::SimpleCrudController
  inherit_resources
  belongs_to :taxon_concept
  before_filter :load_taxon_relationship_types, :only => [:index, :create]

  def index
    index! do
      @designations = Designation.order(:name).where('id <> ?', @taxon_concept.designation_id) #for Inter-designational relationships
      @inverse_taxon_relationships = TaxonRelationship.where(:other_taxon_concept_id => @taxon_concept.id, :taxon_relationship_type_id => @taxon_relationship_type.id).page(params[:page])
    end
  end

  def create
    create! do |success, failure|
      success.js { render 'create' }
      failure.js {
        @designations = Designation.order(:name). #for Inter-designational relationships
          where('id <> ?', TaxonConcept.find(params[:taxon_relationship][:taxon_concept_id]).
          try(:designation_id))
        render 'admin/simple_crud/new'
      }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to collection_url(:type => params[:type]), :notice => 'Operation succeeded' }
    end
  end

  protected

  def load_taxon_relationship_types
    if params[:taxon_relationship]
      @taxon_relationship_type = TaxonRelationshipType.find(
        params[:taxon_relationship][:taxon_relationship_type_id])
    else
      @taxon_relationship_type = TaxonRelationshipType.find_by_name(
        params[:type] || TaxonRelationshipType::EQUAL_TO
      )
    end
    @taxon_relationship_types = TaxonRelationshipType.order(:name).
      inter_designational
  end

  def collection
    @taxon_relationships ||= end_of_association_chain.
      joins(:taxon_relationship_type).
      where(:"taxon_relationship_types.name" => @taxon_relationship_type.name).
      page(params[:page])
  end
end

