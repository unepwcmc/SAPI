class Api::V1::TaxonConceptsController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c| c.params }
  caches_action :show, :cache_path => Proc.new { |c| c.params }
  cache_sweeper :taxon_concept_sweeper

  def index
    if params[:autocomplete]
      matcher = Species::TaxonConceptPrefixMatcher.new(params)
      @taxon_concepts = matcher.taxon_concepts.limit(params[:per_page])
      render :json => @taxon_concepts,
        :each_serializer => Species::AutocompleteTaxonConceptSerializer,
        :meta => {
          :total => matcher.taxon_concepts.count,
          :rank_headers => @taxon_concepts.map(&:rank_name).uniq.map do |r|
            {
              :rank_name => r, 
              :taxon_concept_ids => @taxon_concepts.select{|tc| tc.rank_name == r}.map(&:id)
            }
          end
        }
    else
      @search = Species::Search.new(params)
      @taxon_concepts = @search.results.page(params[:page]).per(params[:per_page] || 50)
      render :json => @taxon_concepts,
        :each_serializer => Species::TaxonConceptSerializer,
        :meta => {
          :total => @search.results.count,
          :higher_taxa_headers => Checklist::HigherTaxaInjector.new(@taxon_concepts).run_summary
        }  
    end

  end

  def show
    @taxon_concept = TaxonConcept.where(:id => params[:id]).
      includes(:common_names => :language,
               :distributions => :geo_entity,
               :quotas => :geo_entity,
               :cites_suspensions => :geo_entity).
      includes(:taxonomy).first
    render :json => @taxon_concept,
      :serializer => Species::ShowTaxonConceptSerializer
  end

end
