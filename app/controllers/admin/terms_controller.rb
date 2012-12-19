class Admin::TermsController < Admin::AdminController
  inherit_resources
  respond_to :js, :only => [:create]
  respond_to :json, :only => [:update]

  def index
    index! do |format|
      format.html { render :template => 'admin/trade_codes/index' }
    end
  end

  def create
    create! do |success, failure|
      success.html { redirect_to collection_url, :notice => 'Operation succeeded' }
      success.js { render :template => 'admin/trade_codes/create' }
      failure.html { redirect_to collection_url, :alert => 'Operation failed' }
      failure.js { render :template => 'admin/trade_codes/new' }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to collection_url, :notice => 'Operation succeeded' }
      failure.html { redirect_to collection_url, :alert => 'Operation failed' }
    end
  end

  protected

  def collection
    @terms ||= end_of_association_chain.order('code').page(params[:page])
  end
end