class SpeciesListingsController < ApplicationController
  caches_action :index

  def index
    render :json => SpeciesListing.
      select([:"species_listings.id", :abbreviation]).
      joins(:designation).
      where(:"designations.name" => params[:designation]).
      order(:abbreviation).all
  end
end
