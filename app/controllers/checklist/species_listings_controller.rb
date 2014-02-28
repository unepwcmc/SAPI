#TODO remove this once Checklist is upgraded to use the API
class Checklist::SpeciesListingsController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c|
    { :designation => Designation::CITES, :locale => "en" }.
      merge(c.params.select{|k,v| !v.blank? && [:designation, :locale].include?(k)})
    }

  def index
    render :text => SpeciesListing.
      select([:"species_listings.id", :abbreviation]).
      joins(:designation).
      where(:"designations.name" => params[:designation] && params[:designation].upcase || Designation::CITES).
      order(:abbreviation).all.to_json
  end
end
