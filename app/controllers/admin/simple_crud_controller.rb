class Admin::SimpleCrudController < Admin::AdminController
  inherit_resources
  respond_to :js, :only => [:create]
  respond_to :json, :only => [:update]

  def create
    create! do |success, failure|
      success.js { render 'create' }
      failure.js { render 'new' }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to collection_url, :notice => 'Operation succeeded' }
      failure.html { redirect_to collection_url, :alert => 'Operation failed' }
    end
  end

end
