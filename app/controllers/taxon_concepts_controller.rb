class TaxonConceptsController < ApplicationController
  def index
    c = Checklist.new(:country_ids => params[:country_ids] ? [params[:country_ids]] : nil)
    render :json => c.generate
  end
end
