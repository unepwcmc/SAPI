class Api::V1::TaxonConceptsController < ApplicationController

  def index
    @search = Species::Search.new(params)
    @taxon_concepts = @search.results.page(params[:page]).per(5)
    render :json => @taxon_concepts,
      :each_serializer => Species::TaxonConceptSerializer


    headers["X-Pagination"] = {
      total_cnt: @search.results.count
    }.to_json

  end

end
