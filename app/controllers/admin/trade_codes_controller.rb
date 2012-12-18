class Admin::TradeCodesController < Admin::AdminController
  inherit_resources

  protected

  def collection
    @trade_codes ||= end_of_association_chain.order('code').page(params[:page])
  end
end