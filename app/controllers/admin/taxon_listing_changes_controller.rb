class Admin::TaxonListingChangesController < Admin::SimpleCrudController
  respond_to :js, :only => [:create, :update]
  defaults :resource_class => ListingChange,
    :collection_name => 'listing_changes', :instance_name => 'listing_change'
  belongs_to :taxon_concept, :designation
  before_action :load_search, :except => [:create, :update, :destroy]
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
    @listing_change = ListingChange.new(listing_change_params)

    if @taxon_concept.listing_changes << @listing_change
      redirect_to admin_taxon_concept_designation_listing_changes_url(@taxon_concept, @designation)
    else
      load_change_types
      build_dependants
      load_search
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
        listing_change_params[:party_listing_distribution_attributes]
      )
    end
    unless @listing_change.annotation
      @listing_change.build_annotation(
        params[:listing_change] &&
        listing_change_params[:annotation_attributes]
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
      where(:is_current => true, :geo_entity_types => { :name => ['COUNTRY', 'REGION'] })
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

  private

  def listing_change_params
    params.require(:listing_change).permit(
      :taxon_concept_id, :species_listing_id, :change_type_id,
      :effective_at, :is_current, :parent_id,
      :inclusion_taxon_concept_id, :hash_annotation_id, :event_id,
      :internal_notes,
      :excluded_taxon_concepts_ids, # String
      :nomenclature_note_en, :nomenclature_note_es, :nomenclature_note_fr,
      :created_by_id, :updated_by_id,
      annotation_attributes: [
        :listing_change_id, :symbol, :parent_symbol, :short_note_en,
        :full_note_en, :short_note_fr, :full_note_fr, :short_note_es, :full_note_es,
        :display_in_index, :display_in_footnote, :event_id, :id, :_destroy
      ],
      party_listing_distribution_attributes: [
        :id, :_destroy, :geo_entity_id, :listing_change_id, :is_party
      ],
      geo_entity_ids: [],
      excluded_geo_entities_ids: []
    )
  end
end
