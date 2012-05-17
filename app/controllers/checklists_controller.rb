class ChecklistsController < ApplicationController
  def index
    roots = TaxonConcept.where(:parent_id => nil).includes(:taxon_name)
    render :json => roots.to_json(:include => :taxon_name)
  end
end
