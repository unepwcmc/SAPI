class Checklist::TimelinesController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c| c.params }
  cache_sweeper :timeline_sweeper

  def index
    return render :json => []  if params[:taxon_concept_ids].nil?

    taxon_concept_ids = params[:taxon_concept_ids].split(',')

    res = MTaxonConcept.find(taxon_concept_ids).map do |tc|
      Checklist::TimelinesForTaxonConcept.new(tc)
    end
    render :json =>  res, :each_serializer => Checklist::TimelinesForTaxonConceptSerializer
  end

  private
  # this disables json root for this controller
  # remove when checklist frontent upgraded to new Ember.js
  def default_serializer_options
    {
      root: false
    }
  end

end
