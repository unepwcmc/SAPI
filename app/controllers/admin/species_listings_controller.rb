class Admin::SpeciesListingsController < Admin::StandardAuthorizationController
protected

  def collection
    @species_listings ||= end_of_association_chain.includes(
      :designation
    ).order(
      'designation_id, species_listings.name'
    ).page(
      params[:page]
    ).search(
      params[:query]
    )
  end

  def load_associations
    @designations = Designation.order(:name)
  end

private

  def species_listing_params
    params.expect(species_listing: [ :designation_id, :name, :abbreviation ])
  end
end
