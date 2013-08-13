class Admin::ListingChangesController < Admin::SimpleCrudController
  respond_to :js, :only => [:create, :update]
  belongs_to :taxon_concept, :designation
  before_filter :load_search, :except => [:create, :update, :destroy]
  layout 'taxon_concepts'

  def index
    index! do
      load_listing_changes
    end
  end

  def new
    new! do
      load_change_types
      build_dependants
    end
  end

  def create
    @taxon_concept = TaxonConcept.find(params[:taxon_concept_id])
    @designation = Designation.find(params[:designation_id])
    @listing_change = ListingChange.new(params[:listing_change])
    if @taxon_concept.listing_changes << @listing_change
      load_listing_changes
      render 'index'
    else
      load_change_types
      build_dependants
      render 'new'
    end
  end

  def edit
    edit! do |format|
      load_change_types
      build_dependants
    end
  end

  def update
    update! do |success, failure|
      success.html {
        redirect_to admin_taxon_concept_designation_listing_changes_url(@taxon_concept, @designation)
      }
      failure.html {
        load_change_types
        build_dependants
        render 'edit'
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
  def build_dependants
    @listing_change.change_type_id ||= @change_types.first.id
    unless @listing_change.party_listing_distribution
      @listing_change.build_party_listing_distribution(
        params[:listing_change] &&
        params[:listing_change][:party_listing_distribution_attributes]
      )
    end
    unless @listing_change.annotation
      @listing_change.build_annotation(
        params[:listing_change] &&
        params[:listing_change][:annotation_attributes]
      )
    end
  end

  def load_change_types
    @change_types = @designation.change_types.order(:name).
      where("name <> '#{ChangeType::EXCEPTION}'")
    @exception_change_type = @designation.change_types.
      find_by_name(ChangeType::EXCEPTION)
    @species_listings = @designation.species_listings.order(:abbreviation)
    @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
      where(:is_current => true, :geo_entity_types => {:name => 'COUNTRY'})
    @hash_annotations = Annotation.for_cites
    @cites_cops = CitesCop.order(:effective_at)
    @events = if @designation.is_eu?
      EuRegulation.order(:effective_at)
    elsif @designation.is_cites?
      @cites_cops
    end
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
