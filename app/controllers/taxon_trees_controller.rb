class TaxonTreesController < ApplicationController
  def index
    roots = TaxonConcept.where(:parent_id => nil)
    render :json => roots.map{ |r| TaxonTree.new(r) }
  end
end
