class Admin::TaxonConceptTermPairsController < Admin::SimpleCrudController
  inherit_resources
  defaults :resource_class => Trade::TaxonConceptTermPair, 
    :collection_name => 'taxon_concept_term_pairs', :instance_name => 'taxon_concept_term_pair'

  protected

  def collection
    @taxon_concept_term_pairs ||= end_of_association_chain.order('term_id').
      page(params[:page])
  end
end