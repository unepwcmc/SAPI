class Admin::SrgHistoriesController < Admin::StandardAuthorizationController
protected

  def collection
    @srg_histories ||= end_of_association_chain.order(
      Arel.sql('UPPER(name) ASC')
    ).page(
      params[:page]
    ).search(
      params[:query]
    )
  end

private

  def srg_history_params
    params.require(:srg_history).permit(
      # attributes were in model `attr_accessible`.
      :name, :tooltip
    )
  end
end
