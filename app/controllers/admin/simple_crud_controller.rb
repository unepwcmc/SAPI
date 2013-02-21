class Admin::SimpleCrudController < Admin::AdminController
  inherit_resources
  respond_to :js, :only => [:create]
  respond_to :json, :only => [:update]

  def index
    load_associations
    index!
  end

  def create
    create! do |success, failure|
      success.js { render 'create' }
      failure.js { load_associations; render 'new' }
    end
  end

  def update
    update! do |success, failure|
      success.js { render 'create' }
      failure.js { load_associations; render 'new' }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to collection_url, :notice => 'Operation succeeded' }
      failure.html { redirect_to collection_url, :alert => 'Operation failed' }
    end
  end

  protected
    def load_associations; end

end