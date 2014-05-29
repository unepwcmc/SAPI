class Admin::UnitsController < Admin::StandardAuthorizationController
  respond_to :json, :only => [:update]
  cache_sweeper :unit_sweeper

  def index
    index! do |format|
      format.html { render :template => 'admin/trade_codes/index' }
    end
  end

  def create
    create! do |success, failure|
      success.js { render :template => 'admin/trade_codes/create' }
      failure.js { render :template => 'admin/trade_codes/new' }
    end
  end

  protected

  def collection
    @units ||= end_of_association_chain.order('code').
      page(params[:page]).
      search(params[:query])
  end
end
