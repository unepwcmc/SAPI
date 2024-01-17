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

  private

  def unit_params
    params.require(:unit).permit(
      :code, :type, :name_en, :name_es, :name_fr
    )
  end
end
