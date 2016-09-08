class Api::V1::DocumentGeoEntitiesController < ApplicationController
  before_filter :set_locale

  def index
    @geo_entities = GeoEntity.current.includes(:geo_entity_type).
      order("name_#{I18n.locale}")
    @geo_entities = @geo_entities.
      joins(:geo_entity_type).
      where(:"geo_entity_types.name" => GeoEntityType::SETS['5'])

    if params[:taxon_concept_query].present?
      @species_search = Species::Search.new({
        visibility: :elibrary,
        taxon_concept_query: params[:taxon_concept_query]
      })
      @geo_entities = @geo_entities.joins(
        document_citation_geo_entities: {
          document_citation: :document_citation_taxon_concepts
        }
      ).where(
        'document_citation_taxon_concepts.taxon_concept_id' => @species_search.ids
      )
    end

    render :json => @geo_entities,
      each_serializer: Species::GeoEntitySerializer,
      meta: { total: @geo_entities.count }
  end

  private

  def set_locale
    locale = params[:locale].try(:downcase).try(:strip) ||
      'en'
    I18n.locale =
      if ['en', 'es', 'fr'].include?(locale)
        locale
      else
        'en'
      end
  end
end
