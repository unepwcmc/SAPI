class Api::V1::TaxonConceptsController < ApplicationController
  # makes params available to the ActiveModel::Serializers
  serialization_scope :view_context
  after_action :track_index, only: :index
  after_action :track_show, only: :show

  def index
    @search = Species::Search.new(params)
    @taxon_concepts = @search.cached_results
    render json: @taxon_concepts,
      each_serializer: Species::TaxonConceptSerializer,
      meta: {
        total: @search.cached_total_cnt,
        higher_taxa_headers: Checklist::HigherTaxaInjector.new(@taxon_concepts).run_summary,
        page: @search.page,
        per_page: @search.per_page
      }
  end

  def show
    @taxon_concept =
      TaxonConcept.includes(
        common_names: :language,
        distributions: :geo_entity,
        quotas: [ :geo_entity, :sources ],
        cites_suspensions: [ :geo_entity, :sources ],
        cites_processes: :geo_entity
      ).includes(:taxonomy).find(params[:id])

    serializer =
      if @taxon_concept.taxonomy.name == Taxonomy::CMS
        Species::ShowTaxonConceptSerializerCms
      else
        Species::ShowTaxonConceptSerializerCites
      end

    render json: @taxon_concept,
      serializer: serializer, trimmed: params[:trimmed]
  end

protected

  def track_index
    ahoy.track 'Search', request.filtered_parameters
  end

  def track_show
    ahoy.track 'Taxon Concept', {
      id: @taxon_concept.id,
      full_name: @taxon_concept.full_name,
      taxonomy_name: @taxon_concept.taxonomy.name,
      rank_name: @taxon_concept.rank_name,
      family_name: @taxon_concept.data['family_name']
    }
  end
end
