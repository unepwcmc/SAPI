class Admin::GeoEntitiesController < Admin::SimpleCrudController
  inherit_resources

  protected

  def collection
    @geo_entities ||= end_of_association_chain.page(params[:page])
  end
end
