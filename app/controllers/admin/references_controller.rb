class Admin::ReferencesController < Admin::StandardAuthorizationController
  respond_to :json, only: [ :index, :update ]

  def index
    index! do |format|
      format.json do
        render json: end_of_association_chain.order(:citation).
          select([ :id, :citation ]).map { |d| { value: d.id, text: d.citation } }.to_json
      end
    end
  end

  def autocomplete
    @references = Reference.search(params[:query]).
      order(:citation)
    @references =
      @references.map do |r|
        {
          id: r.id,
          value: r.citation
        }
      end

    render json: @references.to_json
  end

protected

  def collection
    @references ||= end_of_association_chain.order(:citation).
      page(params[:page]).
      search(params[:query])
  end

private

  def reference_params
    params.require(:reference).permit(
      # attributes were in model `attr_accessible`.
      :citation, :created_by_id, :updated_by_id
    )
  end
end
