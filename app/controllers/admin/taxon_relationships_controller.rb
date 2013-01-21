class Admin::TaxonRelationshipsController < Admin::SimpleCrudController

  belongs_to :taxon_concept
  before_filter :load_taxon_relationship_types, :only => [:index, :create]

  def index
    index! do
      @designations = Designation.order(:name). #for Inter-designational relationships
        where('id <> ?', @taxon_concept.designation_id)
      @inverse_taxon_relationships = TaxonRelationship.
        where(:other_taxon_concept_id => @taxon_concept.id,
          :taxon_relationship_type_id => @taxon_relationship_type.id).
          page(params[:page])
    end
  end

  def create
    # The following line makes sure that we are creating the correct taxon_relationship
    # As we are using the *belongs_to* in this controller *inherit_resources* would
    # create the new taxon_relationship through the parent object like so:
    # => @taxon_concept.taxon_relationships.create, We don't want this
    # we want it to use the information that comes from the form in the params hash.
    # We still want the @taxon_concept variable to be instantiated, so we keep using
    # the *belongs_to* helper for that.
    @taxon_relationship = TaxonRelationship.new(params[:taxon_relationship])

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
    # The following line makes sure that the action will find and destroy the taxon_relationship
    # based solely on the id sent in the params hash. If we do not do this the *belongs_to* helper
    # will cause *inherit_resources* to try to find the taxon_relationship in the parent object's
    # taxon relationships: @taxon_concept.taxon_relationships.find(params[:id]), and it won't find
    # it if that @taxon_concept is the *other_taxon_concept_id* in the taxon_relationship and not
    # the *taxon_concept_id*.
    @taxon_relationship = TaxonRelationship.find(params[:id])
    type = @taxon_relationship.taxon_relationship_type.name
    destroy! do |success, failure|
      success.html { redirect_to collection_url(:type => type), :notice => 'Operation succeeded' }
    end
  end

  protected

  def load_taxon_relationship_types
    @taxon_relationship_type = if params[:taxon_relationship]
       TaxonRelationshipType.find(params[:taxon_relationship][:taxon_relationship_type_id])
      else
       TaxonRelationshipType.find_by_name(params[:type] || TaxonRelationshipType::EQUAL_TO)
    end
    @taxon_relationship_types = TaxonRelationshipType.order(:name).
      interdesignational
  end

  def collection
    @taxon_relationships ||= end_of_association_chain.
      joins(:taxon_relationship_type).
      where(:"taxon_relationship_types.name" => @taxon_relationship_type.name).
      page(params[:page])
  end
end

