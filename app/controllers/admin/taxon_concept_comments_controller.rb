class Admin::TaxonConceptCommentsController < Admin::SimpleCrudController
  defaults :resource_class => Comment, :collection_name => 'comments',
    :instance_name => 'comment'
  belongs_to :taxon_concept
  before_filter :load_search
  layout 'taxon_concepts'
  authorize_resource :class => false

  def index
    @taxon_concept = TaxonConcept.find(params[:taxon_concept_id])
    @taxon_concept.general_comment ||= @taxon_concept.build_general_comment
    @taxon_concept.nomenclature_comment ||= @taxon_concept.build_nomenclature_comment
    @taxon_concept.distribution_comment ||= @taxon_concept.build_distribution_comment
  end

  def create
    @taxon_concept = TaxonConcept.find(params[:taxon_concept_id])
    @comment = @taxon_concept.comments.create(params[:comment])
    redirect_to admin_taxon_concept_comments_url(@taxon_concept),
      notice: 'Operation succeeded'
  end

  def update
    @taxon_concept = TaxonConcept.find(params[:taxon_concept_id])
    @comment = @taxon_concept.comments.find(params[:id])
    @comment.update_attributes(params[:comment])
    redirect_to admin_taxon_concept_comments_url(@taxon_concept),
      notice: 'Operation succeeded'
  end
end
