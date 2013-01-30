class Admin::ListingChangesController < Admin::SimpleCrudController
  respond_to :js, :only => [:new, :edit, :create, :update]
  belongs_to :taxon_concept, :designation
  layout 'taxon_concepts'

  def new
    new! do
      load_change_types
      @listing_change.build_party_listing_distribution
      @listing_change.listing_distributions.build
    end
  end

  def create
    params[:listing_change][:geo_entity_ids] &&
      params[:listing_change][:geo_entity_ids].delete("")
    create! do |success, failure|
      failure.js {
        load_change_types
        render "new"
      }
    end
  end

  def edit
    edit! do |format|
      load_change_types
      format.js { render 'new' }
    end
  end

  def update
    update! do |success, failure|
      success.js { render 'create' }
      failure.js {
        load_change_types
        render 'new'
      }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html {
        redirect_to admin_taxon_concept_designation_listing_changes_url(@taxon_concept, @designation),
        :notice => 'Operation successful'
      }
    end
  end

  protected
  def load_change_types
    @change_types = ChangeType.order(:name).
      where(:designation_id => @designation.id)
    @species_listings = SpeciesListing.order(:abbreviation).
      where(:designation_id => @designation.id)
    @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
      where(:is_current => true, :geo_entity_types => {:name => 'COUNTRY'})
  end

  def collection
    @listing_changes ||= end_of_association_chain.
      order('effective_at desc, is_current desc').
      page(params[:page]).where(:parent_id => nil)
  end
end
