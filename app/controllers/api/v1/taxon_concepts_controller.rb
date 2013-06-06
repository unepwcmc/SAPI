class Api::V1::TaxonConceptsController < ApplicationController

  def index
    @search = Species::Search.new(params)
    @taxon_concepts = @search.results.page(params[:page]).per(5)
    render :json => @taxon_concepts,
      :each_serializer => Species::TaxonConceptSerializer,
      :meta => {:total => @search.results.count}
  end

  def show
    render :json => MTaxonConcept.where(:rank_name => 'SPECIES').first,
      :serializer => Species::TaxonConceptSerializer
  end

end
