class Admin::TaxonRelationshipsController < Admin::SimpleCrudController
  inherit_resources
  belongs_to :taxon_concept
  before_filter :load_taxon_relationship_types, :only => [:index, :create]
  before_filter :load_taxon_concepts, :only => [:index, :create]

  def index
    index! do
      @inverse_taxon_relationships = TaxonRelationship.where(:other_taxon_concept_id => @taxon_concept.id).page(params[:page])
    end
  end

  protected

  def load_taxon_relationship_types
    @taxon_relationship_type = TaxonRelationshipType.find_by_name(
      params[:type] || TaxonRelationshipType::EQUAL_TO
    )
    @taxon_relationship_types = TaxonRelationshipType.order(:name)
    @taxon_relationship_types_for_dropdown = @taxon_relationship_types.map do |t|
      {:value => t.id, :text => t.name}
    end
  end

  def load_taxon_concepts
    @taxon_concepts = TaxonConcept.order(:id)
    @taxon_concepts_for_dropdown = @taxon_concepts.map do |t|
      {:value => t.id, :text => t.full_name}
    end
  end

  def collection
    @taxon_relationships ||= end_of_association_chain.
      joins(:taxon_relationship_type).
      where(:"taxon_relationship_types.name" => @taxon_relationship_type.name).
      page(params[:page])
  end

end

