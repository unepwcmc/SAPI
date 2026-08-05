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
    params.expect(srg_history: [ :name, :tooltip ])
  end
end
