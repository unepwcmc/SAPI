class Admin::TaxonConceptReferencesController < Admin::SimpleCrudController
  defaults :resource_class => TaxonConceptReference, :collection_name => 'taxon_concept_references', :instance_name => 'taxon_concept_reference'
  belongs_to :taxon_concept
  respond_to :js, :only => [:new, :create]

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
