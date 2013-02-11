class Admin::ListingChangesController < Admin::SimpleCrudController
  respond_to :js, :only => [:new, :edit, :create, :update]
  belongs_to :taxon_concept, :designation
  layout 'taxon_concepts'

  def index
    index! do
      load_listing_changes
    end
  end

  def new
    new! do
      load_change_types
      @listing_change.build_party_listing_distribution
      @listing_change.exclusions.build
      @listing_change.build_annotation
    end
  end

  def create
    @taxon_concept = TaxonConcept.find(params[:taxon_concept_id])
    @designation = Designation.find(params[:designation_id])
    @listing_change = ListingChange.new(params[:listing_change])
    if @taxon_concept.listing_changes << @listing_change
      load_listing_changes
      render 'create'
    else
      load_change_types
      @listing_change.build_party_listing_distribution(params[:listing_change][:party_listing_distribution_attributes])
      @listing_change.build_annotation(params[:listing_change][:annotation_attributes])
      render 'new'
    end
  end

  def edit
    edit! do |format|
      load_change_types
      unless @listing_change.party_listing_distribution
        @listing_change.build_party_listing_distribution
      end
      unless @listing_change.exclusions
        @listing_change.exclusions.build
      end
      unless @listing_change.annotation
        @listing_change.build_annotation
      end
      format.js { render 'new' }
    end
  end

  def update
    update! do |success, failure|
      success.js {
        load_listing_changes
        render 'create'
      }
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
      where("name <> '#{ChangeType::EXCEPTION}'").
      where(:designation_id => @designation.id)
    @exception_change_type = ChangeType.
      where(:designation_id => @designation.id).
      find_by_name(ChangeType::EXCEPTION)
    @species_listings = SpeciesListing.order(:abbreviation).
      where(:designation_id => @designation.id)
    @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
      where(:is_current => true, :geo_entity_types => {:name => 'COUNTRY'})
  end

  def load_listing_changes
    @listing_changes = @taxon_concept.listing_changes.
      includes([
        :species_listing,
        :change_type,
        :party_geo_entity,
        :geo_entities,
        :exclusions => [:geo_entities, :taxon_concept]
      ]).
      where("change_types.name <> '#{ChangeType::EXCEPTION}'").
      where("change_types.designation_id" => @designation.id).
      order('listing_changes.effective_at DESC').
      page(params[:page]).where(:parent_id => nil)
  end
end
