class Api::V1::TaxonConceptsController < ApplicationController

  def index
    @search = Species::Search.new(params)
    @taxon_concepts = @search.cached_results
    render :json => @taxon_concepts,
      :each_serializer => Species::TaxonConceptSerializer,
      :meta => {
        :total => @search.cached_total_cnt,
        :higher_taxa_headers => Checklist::HigherTaxaInjector.new(@taxon_concepts).run_summary,
        :page => params[:page]
      }  
  end

  def show
    @taxon_concept = TaxonConcept.where(:id => params[:id]).
      includes(:common_names => :language,
               :distributions => :geo_entity,
               :quotas => :geo_entity,
               :cites_suspensions => :geo_entity).
      includes(:taxonomy).first
    if @taxon_concept.taxonomy.name == Taxonomy::CMS
      s = Species::ShowTaxonConceptSerializerCms
    else
      s = Species::ShowTaxonConceptSerializerCites
    end
    render :json => @taxon_concept,
      :serializer => s
  end
end
