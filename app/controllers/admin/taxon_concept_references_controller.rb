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
    taxon_concept_reference = TaxonConceptReference.where(
      "reference_id = ? AND taxon_concept_id = ?",
      params[:id], params[:taxon_concept_id]
    ).first

    if taxon_concept_reference.delete
      redirect_to edit_admin_taxon_concept_url(params[:taxon_concept_id]),
      :notice => 'Operation successful'
    else
      redirect_to edit_admin_taxon_concept_url(params[:taxon_concept_id]),
      :notice => 'Operation failed'
    end
  end
end
