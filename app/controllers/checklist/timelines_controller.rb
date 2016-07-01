class Checklist::TimelinesController < ApplicationController

  def index
    return render :json => []  if params[:taxon_concept_ids].nil?
    return render :json => []  unless params[:taxon_concept_ids].kind_of?(Array)
    res = params[:taxon_concept_ids].map do |tc_id|
      tc = MTaxonConcept.find_by_id(tc_id)
      Checklist::TimelinesForTaxonConcept.new(tc) unless tc.nil?
    end
    render :json => res, :each_serializer => Checklist::TimelinesForTaxonConceptSerializer
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
