class Admin::TaxonInstrumentsController < Admin::TaxonConceptAssociatedTypesController
  respond_to :js, only: [ :create, :update ]
  belongs_to :taxon_concept
  before_action :load_search, only: [ :new, :index, :edit, :create ]
  layout 'taxon_concepts'

  def index
    index! do
      load_taxon_instruments
    end
  end

  def new
    new! do
      load_instruments
    end
  end

  def create
    @taxon_concept = TaxonConcept.find(params[:taxon_concept_id])
    @taxon_instrument = TaxonInstrument.new(taxon_instrument_params)
    if @taxon_concept.taxon_instruments << @taxon_instrument
      load_taxon_instruments
      render 'index'
    else
      load_instruments
      render 'new'
    end
  end

  def update
    update! do |success, failure|
      success.html do
        redirect_to admin_taxon_concept_taxon_instruments_url(@taxon_concept)
      end
      failure.html do
        load_instruments
        render 'edit'
      end
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html do
        redirect_to admin_taxon_concept_taxon_instruments_url(@taxon_concept),
          notice: 'Operation successful'
      end
    end
  end

protected

  def load_instruments
    @taxon_instrument = TaxonInstrument.new(taxon_concept_id: @taxon_concept.id)
    @instruments = Instrument.joins(designation: :taxonomy).
      where(taxonomies: { id: @taxon_concept.taxonomy_id }).
      order(:name)
  end

  def load_taxon_instruments
    @taxon_instruments = @taxon_concept.taxon_instruments.
      includes(:instrument).
      page(params[:page])
  end

private

  def taxon_instrument_params
    params.require(:taxon_instrument).permit(
      # attributes were in model `attr_accessible`.
      :effective_from, :instrument_id, :taxon_concept_id
    )
  end
end
