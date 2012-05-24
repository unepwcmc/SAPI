class TaxonConceptsController < ApplicationController
  def index
    c = Checklist.new(:country_ids => params[:country_id] ? [params[:country_id]] : nil)
    render :json => c.generate
  end
end
