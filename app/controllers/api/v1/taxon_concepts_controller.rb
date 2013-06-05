class Api::V1::TaxonConceptsController < ApplicationController

  def index
    @search = Species::Search.new(params)
    render :json => @search.generate(params[:page], 5).results,
      :each_serializer => Species::TaxonConceptSerializer
  end

end
