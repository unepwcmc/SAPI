class Admin::ListingChangesController < Admin::SimpleCrudController

  belongs_to :taxon_concept, :optional => true
  before_filter :load_change_types, :only => [:index, :create]
  layout 'taxon_concepts'

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to admin_taxon_concept_listing_changes_url(params[:taxon_concept_id]),
        :notice => 'Operation successful'
      }
    end
  end

  protected
  def load_change_types
    @taxon_concept ||= TaxonConcept.find(params[:taxon_concept_id])
    @change_types = ChangeType.order(:name).
      where(:designation_id => @taxon_concept.designation_id)
    @species_listings = SpeciesListing.order(:abbreviation).
      where(:designation_id => @taxon_concept.designation_id)
    @geo_entities = GeoEntity.order(:name_en).where(:is_current => true)
  end

  def collection
    @listing_changes ||= end_of_association_chain.
      order('effective_at desc, is_current desc').
      page(params[:page]).where(:parent_id => nil)
  end
end
