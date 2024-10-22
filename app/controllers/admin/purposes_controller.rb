class Admin::PurposesController < Admin::StandardAuthorizationController
  respond_to :json, only: [ :update ]

  def index
    index! do |format|
      format.html { render template: 'admin/trade_codes/index' }
    end
  end

  def create
    create! do |success, failure|
      success.js { render template: 'admin/trade_codes/create' }
      failure.js { render template: 'admin/trade_codes/new' }
    end
  end

protected

  def collection
    @purposes ||= end_of_association_chain.order(
      'code'
    ).page(
      params[:page]
    ).search(
      params[:query]
    )
  end

private

  def purpose_params
    params.require(:purpose).permit(
      # attributes were in model `attr_accessible`.
      :code, :type, :name_en, :name_es, :name_fr
    )
  end
end
