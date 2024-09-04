class Admin::DesignationsController < Admin::StandardAuthorizationController
  respond_to :json, only: [ :index, :update ]

  def index
    load_associations
    @custom_title = 'MEAs'
    index! do |format|
      format.json do
        render json: end_of_association_chain.order(:name).
          select([ :id, :name ]).map { |d| { value: d.id, text: d.name } }.to_json
      end
    end
  end

protected

  def collection
    @designations ||= end_of_association_chain.order(
      :name
    ).page(
      params[:page]
    ).search(
      params[:query]
    )
  end

  def load_associations
    @taxonomies = Taxonomy.order(:name)
  end

private

  def designation_params
    params.require(:designation).permit(
      # attributes were in model `attr_accessible`.
      :name, :taxonomy_id
    )
  end
end
