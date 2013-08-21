class Api::V1::TaxonConceptsController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c| c.params }
  cache_sweeper :taxon_concept_sweeper

  def index
    @search = Species::Search.new(params)
    @taxon_concepts = @search.results.page(params[:page]).per(params[:per_page] || 50)
    render :json => @taxon_concepts,
      :each_serializer => Species::TaxonConceptSerializer,
      :meta => {
        :total => @search.results.count,
        :higher_taxa_headers => Checklist::HigherTaxaInjector.new(@taxon_concepts).run_summary
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
