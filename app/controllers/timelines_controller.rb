class TimelinesController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c| c.params }
  cache_sweeper :timeline_sweeper

  def index
    return render :json => []  if params[:taxon_concept_ids].nil?

    taxon_concept_ids = params[:taxon_concept_ids].split(',')
    res = taxon_concept_ids.map do |id|
      TimelinesForTaxonConcept.new(id).to_json
    end
    render :json => res
  end
end
