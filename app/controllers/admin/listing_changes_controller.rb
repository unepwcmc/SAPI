class Admin::ListingChangesController < Admin::SimpleCrudController

  belongs_to :taxon_concept, :optional => true
  before_filter :load_change_types, :only => [:index, :create]
  layout 'taxon_concepts'

  protected
  def load_change_types
    @taxon_concept ||= TaxonConcept.find(params[:taxon_concept_id])
    @change_types = ChangeType.order(:name).joins(:designation).
      where(:"designations.taxonomy_id" => @taxon_concept.taxonomy_id)
    @species_listings = SpeciesListing.order(:abbreviation).joins(:designation).
      where(:"designations.taxonomy_id" => @taxon_concept.taxonomy_id)
  end

  def collection
    @listing_changes ||= end_of_association_chain.
      order('effective_at desc, is_current desc').
      page(params[:page]).where(:parent_id => nil)
  end
end
