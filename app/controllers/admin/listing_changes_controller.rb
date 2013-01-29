class Admin::ListingChangesController < Admin::SimpleCrudController

  belongs_to :taxon_concept, :optional => true
  before_filter :load_change_types, :only => [:index, :create]
  layout 'taxon_concepts'

  protected
  def load_change_types #TODO this method needs to know the designation
    @taxon_concept ||= TaxonConcept.find(params[:taxon_concept_id])
    @change_types = ChangeType.order(:name).
      where(:designation_id => @taxon_concept.designation_id)
    @species_listings = SpeciesListing.order(:abbreviation).
      where(:designation_id => @taxon_concept.designation_id)
  end

  def collection
    @listing_changes ||= end_of_association_chain.
      order('effective_at desc, is_current desc').
      page(params[:page]).where(:parent_id => nil)
  end
end
