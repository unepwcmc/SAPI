class Api::V1::TaxonConceptsController < ApplicationController

  def index
    @search = Species::Search.new(params)
    @taxon_concepts = @search.results.page(params[:page]).per(5)
    render :json => @taxon_concepts,
      :each_serializer => Species::TaxonConceptSerializer,
      :meta => {:total => @search.results.count}
  end

  def show
    @taxon_concept = MTaxonConcept.find(params[:id])
    render :json => @taxon_concept,
      :serializer => Species::TaxonConceptSerializer
  end

end
