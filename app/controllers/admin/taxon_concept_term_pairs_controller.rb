class Admin::TaxonConceptTermPairsController < Admin::SimpleCrudController

  before_filter :load_term_codes, :only => [:index, :create]
  defaults :resource_class => Trade::TaxonConceptTermPair,
    :collection_name => 'taxon_concept_term_pairs', :instance_name => 'taxon_concept_term_pair'

  authorize_resource :class => Trade::TaxonConceptTermPair

  protected

  def load_term_codes
    @term_codes_obj = Term.select([:id, :code]).
      map { |c| { "id" => c.id, "code" => c.code } }.to_json
  end

  def collection
    @taxon_concept_term_pairs ||= end_of_association_chain.order('term_id').
      page(params[:page]).
      search(params[:query])
  end
end
