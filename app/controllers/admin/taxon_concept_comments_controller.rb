class Admin::TaxonConceptCommentsController < Admin::SimpleCrudController
  defaults resource_class: Comment, collection_name: 'comments',
    instance_name: 'comment'
  belongs_to :taxon_concept
  before_action :load_search
  layout 'taxon_concepts'
  authorize_resource class: false

  def index
    @taxon_concept = TaxonConcept.find(params[:taxon_concept_id])
    @taxon_concept.general_comment ||= @taxon_concept.build_general_comment
    @taxon_concept.nomenclature_comment ||= @taxon_concept.build_nomenclature_comment
    @taxon_concept.distribution_comment ||= @taxon_concept.build_distribution_comment
  end

  def create
    @taxon_concept = TaxonConcept.find(params[:taxon_concept_id])
    @comment = @taxon_concept.comments.create(comment_params)
    redirect_to admin_taxon_concept_comments_url(@taxon_concept),
      notice: 'Operation succeeded'
  end

  def update
    @taxon_concept = TaxonConcept.find(params[:taxon_concept_id])
    @comment = @taxon_concept.comments.find(params[:id])
    @comment.update(comment_params)
    redirect_to admin_taxon_concept_comments_url(@taxon_concept),
      notice: 'Operation succeeded'
  end

private

  def comment_params
    params.require(:comment).permit(
      # attributes were in model `attr_accessible`.
      :comment_type, :commentable_id, :commentable_type, :note,
      :created_by_id, :updated_by_id
    )
  end
end
