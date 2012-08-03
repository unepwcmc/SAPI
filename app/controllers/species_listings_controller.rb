class SpeciesListingsController < ApplicationController
  def index
    render :json => SpeciesListing.
      select([:"species_listings.id", :abbreviation]).
      joins(:designation).
      where(:"designations.name" => params[:designation]).
      order(:abbreviation).all + [
        {id: 0, abbreviation: 'nc'}
      ]
  end
end
