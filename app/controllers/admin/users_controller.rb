class Admin::UsersController < Admin::SimpleCrudController
  inherit_resources

  protected
    def collection
      @users ||= end_of_association_chain.order(:name).page(params[:page])
    end
end

