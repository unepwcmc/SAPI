class Admin::TaxonConceptReferencesController < Admin::StandardAuthorizationController
  defaults :resource_class => TaxonConceptReference, :collection_name => 'taxon_concept_references', :instance_name => 'taxon_concept_reference'
  belongs_to :taxon_concept
  before_filter :load_search, :only => [:index]
  respond_to :js, :only => [:new, :create]
  layout 'taxon_concepts'

  def index
    @taxon_concept_reference = TaxonConceptReference.new
    index!
  end

  def new
    @taxon_concept_reference = TaxonConceptReference.new
    @taxon_concept_reference.reference = Reference.new
    @references = TaxonConceptReference.where(:taxon_concept_id => params["taxon_concept_id"])
    new!
  end

  def create
    @references = TaxonConceptReference.where(:taxon_concept_id => params["taxon_concept_id"])

    reference_id = params["reference"] && params["reference"]["id"]
    unless reference_id.blank?
      @taxon_concept_reference = TaxonConceptReference.new(
        :taxon_concept_id => params["taxon_concept_id"],
        :reference_id     => reference_id,
        :is_standard => "1" == params[:taxon_concept_reference][:is_standard],
        :is_cascaded => "1" == params[:taxon_concept_reference][:is_cascaded],
        :excluded_taxon_concepts_ids => params[:taxon_concept_reference][:excluded_taxon_concepts_ids]
      )
    end

    create! do |success, failure|
      success.js {
        @taxon_concept_reference = TaxonConceptReference.new
        @taxon_concept_reference.reference = Reference.new
        render 'create'
      }
      failure.js { render 'new' }
    end
  end

  def edit
    edit! do |format|
      format.js { render 'new' }
    end
  end

  def update
    update! do |success, failure|
      success.js {
        @taxon_concept_reference = TaxonConceptReference.new
        @taxon_concept_reference.reference = Reference.new
        render 'create'
      }
      failure.js { render 'new' }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html {
        redirect_to admin_taxon_concept_taxon_concept_references_path(@taxon_concept),
        :notice => 'Operation successful'
      }
      failure.html {
        redirect_to admin_taxon_concept_taxon_concept_references_path(@taxon_concept),
        :notice => 'Operation failed'
      }
    end
  end
end
