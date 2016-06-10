class Checklist::GeoEntitiesController < ApplicationController

  def index
    @geo_entities = GeoEntitySearch.new(
      params.slice(:geo_entity_types_set, :locale)
    ).cached_results

    render :json => @geo_entities,
      :each_serializer => Checklist::GeoEntitySerializer
  end

  private

  # this disables json root for this controller
  # remove when checklist frontend upgraded to new Ember.js
  def default_serializer_options
    {
      root: false
    }
  end
end
