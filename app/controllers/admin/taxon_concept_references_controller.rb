class Admin::TaxonConceptReferencesController < Admin::SimpleCrudController
  defaults :resource_class => Reference, :collection_name => 'references', :instance_name => 'reference'
  belongs_to :taxon_concept
  respond_to :js, :only => [:new, :create]

  def new
    new! do |format|
      @reference_relationship = TaxonConceptReference.new(
        :taxon_concept_id => @taxon_concept.id
      )
    end
  end

  def create
    create! do |success, failure|
      success.js {
        @reference_relationship = TaxonConceptReference.new(
          :taxon_concept_id => @taxon_concept.id,
          :reference_id => @reference.id
        )

        @reference_relationship.save!
      }
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
