class Admin::TaxonConceptAssociatedTypesController < Admin::SimpleCrudController
  authorize_resource class: false
  layout 'taxon_concepts'
  belongs_to :taxon_concept

  def destroy
    destroy! do |success, failure|
      success.html do
        redirect_to edit_admin_taxon_concept_url(params[:taxon_concept_id]),
          notice: 'Operation successful'
      end
      failure.html do
        redirect_to edit_admin_taxon_concept_url(params[:taxon_concept_id]),
          notice: 'Operation failed'
      end
    end
  end
end
