class TimelinesController < ApplicationController
  def index
    #TODO
    taxon_concept_id = params[:taxon_concept_ids].split(',').first
    render :json => [TimelinesForTaxonConcept.new(taxon_concept_id).to_json]
  end
end