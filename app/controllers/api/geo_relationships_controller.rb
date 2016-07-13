class Api::GeoRelationshipsController < ApplicationController
  respond_to :json
  inherit_resources

  protected

  def collection
    @geo_relationship_types ||= end_of_association_chain.order(:name).
      select([:id, :name]).
      map { |d| { :value => d.id, :text => d.name } }
  end
end
