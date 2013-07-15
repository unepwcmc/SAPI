class Api::V1::TaxonConceptsController < ApplicationController

  def index
    @search = Species::Search.new(params)
    @taxon_concepts = @search.results.page(params[:page]).per(params[:per_page] || 10)
    render :json => @taxon_concepts,
      :each_serializer => Species::TaxonConceptSerializer,
      :meta => {:total => @search.results.count}
  end

  def show
    @taxon_concept = TaxonConcept.where(:id => params[:id]).
      includes(:common_names => :language,
               :distributions => :geo_entity,
               :quotas => :geo_entity,
               :cites_suspensions => :geo_entity).first
    render :json => @taxon_concept,
      :serializer => Species::ShowTaxonConceptSerializer
  end

  def autocomplete
    matcher = Checklist::TaxonConceptPrefixMatcher.new(
      :scientific_name => params[:scientific_name]
    )
    render :json => matcher.taxon_concepts.limit(params[:per_page]),
      :each_serializer => Species::AutocompleteTaxonConceptSerializer
  end
end
