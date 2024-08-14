class Admin::SpeciesListingsController < Admin::StandardAuthorizationController
protected

  def collection
    @species_listings ||= end_of_association_chain.includes(:designation).
      order('designation_id, species_listings.name').
      page(params[:page]).
      search(params[:query])
  end

  def load_associations
    @designations = Designation.order(:name)
  end

private

  def species_listing_params
    params.require(:species_listing).permit(
      # attributes were in model `attr_accessible`.
      :designation_id, :name, :abbreviation
    )
  end
end
