class TaxonConceptsController < ApplicationController
  def index
    res = if params[:country_id]
      TaxonConcept.by_country(params[:country_id])
    else
      TaxonConcept.all
    end
    render :json => res
  end
end
