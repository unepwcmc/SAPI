class Admin::TaxonConceptAssociatedTypesController < Admin::SimpleCrudController
  authorize_resource class: false
  layout 'taxon_concepts'
  belongs_to :taxon_concept

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
