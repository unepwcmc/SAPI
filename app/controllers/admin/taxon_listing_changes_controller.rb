class Admin::TaxonListingChangesController < Admin::SimpleCrudController
  respond_to :js, :only => [:create, :update]
  defaults :resource_class => ListingChange,
    :collection_name => 'listing_changes', :instance_name => 'listing_change'
  belongs_to :taxon_concept, :designation
  before_filter :load_search, :except => [:create, :update, :destroy]
  layout 'taxon_concepts'

  authorize_resource :class => false

  def index
    index! do
      load_listing_changes
    end
  end

  def new
    new! do
      load_change_types
      @listing_change.change_type_id ||= @change_types.first.id
      @listing_change.is_current = true
      @listing_change.event = @events && @events.first # ordered most recent first
      @listing_change.effective_at =  @listing_change.event && @listing_change.event.effective_at
      build_dependants
    end
  end

  def create
    @taxon_concept = TaxonConcept.find(params[:taxon_concept_id])
    @designation = Designation.find(params[:designation_id])
    @listing_change = ListingChange.new(params[:listing_change])
    if @taxon_concept.listing_changes << @listing_change
      redirect_to admin_taxon_concept_designation_listing_changes_url(@taxon_concept, @designation)
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
        if "1" == params[:redirect_to_eu_reg]
          redirect_to admin_eu_regulation_listing_changes_path(@listing_change.event)
        else
          redirect_to admin_taxon_concept_designation_listing_changes_url(@taxon_concept, @designation)
        end
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
      where(:is_current => true, :geo_entity_types => { :name => 'COUNTRY' })
    @hash_annotations =
      if @designation.is_eu?
        Annotation.for_eu
      elsif @designation.is_cites?
        Annotation.for_cites
      else
        []
      end
    @events =
      if @designation.is_eu?
        EuRegulation.order('effective_at DESC')
      elsif @designation.is_cites?
        CitesCop.order('effective_at DESC')
      else
        []
      end
  end

  def load_listing_changes
    @listing_changes = end_of_association_chain.
      includes([
        :species_listing,
        :change_type,
        :party_geo_entity,
        :geo_entities,
        :exclusions => [:geo_entities, :taxon_concept]
      ]).
      where("change_types.name <> '#{ChangeType::EXCEPTION}'").
      where("change_types.designation_id" => @designation.id).
      where("taxon_concept_id" => @taxon_concept.id).
      order('listing_changes.effective_at DESC').
      page(params[:page]).where(:parent_id => nil)
  end
end
