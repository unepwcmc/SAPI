class CountriesController < ApplicationController
  def index
    render :json => Country.order(:iso_name).all
  end
end
