class ChecklistsController < ApplicationController
  def index
    @animalia = TaxonConcept.find_by_taxon_name_id(
      TaxonName.find_by_scientific_name('Animalia').id
    )
    @plantae = TaxonConcept.find_by_taxon_name_id(
      TaxonName.find_by_scientific_name('Plantae').id
    )
    render :json => {:animalia => @animalia, :plantae => @plantae}
  end
end
