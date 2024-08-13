class Admin::InstrumentsController < Admin::StandardAuthorizationController
  respond_to :json, only: [ :index, :update ]

  def index
    load_associations
    index! do |format|
      format.json do
        render json: end_of_association_chain.order(:name).
          select([ :id, :name ]).map { |d| { value: d.id, text: d.name } }.to_json
      end
    end
  end

protected

  def collection
    @instruments ||= end_of_association_chain.order(:name).
      page(params[:page]).
      search(params[:query])
  end

  def load_associations
    @designations = Designation.order(:name)
  end

private

  def instrument_params
    params.require(:instrument).permit(
      # attributes were in model `attr_accessible`.
      :designation_id, :name
    )
  end
end
