#TODO remove this once Checklist is upgraded to use the API
class Checklist::SpeciesListingsController < ApplicationController
  caches_action :index

  def index
    render :text => SpeciesListing.
      select([:"species_listings.id", :abbreviation]).
      joins(:designation).
      where(:"designations.name" => params[:designation].upcase).
      order(:abbreviation).all.to_json
  end
end
