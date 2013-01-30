class Admin::TaxonConceptGeoEntitiesRelationshipController < Admin::SimpleCrudController
  respond_to :js, :only => [:new, :edit, :create, :update]
  belongs_to :taxon_concept

  def new
    new! do |format|
      puts params
      #@synonym_relationship = TaxonRelationship.new(
        #:taxon_relationship_type_id => @synonym_relationship_type.id
      #)
      #@synonym_relationship.build_other_taxon_concept(
        #:designation_id => @taxon_concept.designation_id,
        #:rank_id => @taxon_concept.rank_id,
        #:name_status => 'S'
      #)
      #@synonym_relationship.other_taxon_concept.build_taxon_name
    end
  end

  def create
    create! do |success, failure|
      failure.js {
        render 'new'
      }
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
end
