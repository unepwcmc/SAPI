class Api::V1::TaxonConceptsController < ApplicationController

  def index
    @search = Species::Search.new(params)
    @taxon_concepts = @search.results.page(params[:page]).per(5)
    render :json => @taxon_concepts,
      :each_serializer => Species::TaxonConceptSerializer,
      :meta => {:total => @search.results.count}
  end

  def show
    @taxon_concept = TaxonConcept.where(:id => params[:id]).
      includes(:common_names => :language,
               :distributions => :geo_entity).first
    render :json => @taxon_concept,
      :serializer => Species::ShowTaxonConceptSerializer
  end

end
