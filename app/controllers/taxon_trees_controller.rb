class TaxonTreesController < ApplicationController
  def index
    render :json => TaxonConcept.roots.map{ |r| TaxonTree.new(r) }
  end
end
