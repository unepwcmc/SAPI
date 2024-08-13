class Admin::TaxonomiesController < Admin::StandardAuthorizationController
  respond_to :json, only: [:index, :update]

  def index
    index! do |format|
      format.json {
        render json: end_of_association_chain.order(:name).
          select([:id, :name]).map { |d| { value: d.id, text: d.name } }.to_json
      }
    end
  end

  protected

  def collection
    @taxonomies ||= end_of_association_chain.order(:name).
      page(params[:page]).
      search(params[:query])
  end

  private

  def taxonomy_params
    params.require(:taxonomy).permit(:name)
  end
end
