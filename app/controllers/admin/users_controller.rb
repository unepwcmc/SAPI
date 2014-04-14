class Admin::UsersController < Admin::SimpleCrudController
  inherit_resources

  def edit
    edit! do |format|
      load_associations
      format.js { render 'new' }
    end
  end

  protected
    def collection
      @users ||= end_of_association_chain.order(:name).page(params[:page])
    end
end

