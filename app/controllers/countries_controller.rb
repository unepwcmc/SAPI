class CountriesController < ApplicationController
  def index
    render :json => [{:iso_name => 'Poland', :iso2_code => 'PL'}, {:iso_name => 'Portugal', :iso2_code => 'PT'}]
  end
end
