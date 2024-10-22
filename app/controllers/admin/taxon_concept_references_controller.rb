class Admin::TaxonConceptReferencesController < Admin::StandardAuthorizationController
  defaults resource_class: TaxonConceptReference, collection_name: 'taxon_concept_references', instance_name: 'taxon_concept_reference'
  belongs_to :taxon_concept
  before_action :load_search, only: [ :index ]
  respond_to :js, only: [ :new, :create ]
  layout 'taxon_concepts'

  def index
    @taxon_concept_reference = TaxonConceptReference.new
    index!
  end

  def new
    @taxon_concept_reference = TaxonConceptReference.new
    @taxon_concept_reference.reference = Reference.new
    @references = TaxonConceptReference.where(taxon_concept_id: params['taxon_concept_id'])
    new!
  end

  def edit
    edit! do |format|
      format.js { render 'new' }
    end
  end
  def create
    @references = TaxonConceptReference.where(taxon_concept_id: params['taxon_concept_id'])

    reference_id = params['reference'] && params['reference']['id']
    if reference_id.present?
      @taxon_concept_reference = TaxonConceptReference.new(
        taxon_concept_id: params['taxon_concept_id'],
        reference_id: reference_id,
        is_standard: '1' == params[:taxon_concept_reference][:is_standard],
        is_cascaded: '1' == params[:taxon_concept_reference][:is_cascaded],
        excluded_taxon_concepts_ids: params[:taxon_concept_reference][:excluded_taxon_concepts_ids]
      )
    end

    create! do |success, failure|
      success.js do
        @taxon_concept_reference = TaxonConceptReference.new
        @taxon_concept_reference.reference = Reference.new
        render 'create'
      end
      failure.js { render 'new' }
    end
  end


  def update
    update! do |success, failure|
      success.js do
        @taxon_concept_reference = TaxonConceptReference.new
        @taxon_concept_reference.reference = Reference.new
        render 'create'
      end
      failure.js { render 'new' }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html do
        redirect_to admin_taxon_concept_taxon_concept_references_path(@taxon_concept),
          notice: 'Operation successful'
      end
      failure.html do
        redirect_to admin_taxon_concept_taxon_concept_references_path(@taxon_concept),
          notice: 'Operation failed'
      end
    end
  end

private

  def taxon_concept_reference_params
    params.require(:taxon_concept_reference).permit(
      # attributes were in model `attr_accessible`.
      :reference_id, :taxon_concept_id, :is_standard, :is_cascaded,
      :created_by_id, :updated_by_id,
      :excluded_taxon_concepts_ids, # String
      reference_attributes: [ :citation, :created_by_id, :updated_by_id, :id, :_destroy ]
    )
  end
end
