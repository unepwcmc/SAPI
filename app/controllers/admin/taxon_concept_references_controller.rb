class Admin::TaxonConceptReferencesController < Admin::SimpleCrudController
  defaults :resource_class => Reference, :collection_name => 'references', :instance_name => 'reference'
  belongs_to :taxon_concept
  respond_to :js, :only => [:new, :create]
end
