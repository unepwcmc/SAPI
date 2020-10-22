class Admin::SrgHistoriesController < Admin::StandardAuthorizationController
  protected

  def collection
    @srg_histories ||= end_of_association_chain.page(params[:page]).
      order('UPPER(name) ASC')
  end
end
