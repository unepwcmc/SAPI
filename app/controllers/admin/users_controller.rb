class Admin::UsersController < Admin::AdminController
  inherit_resources

  protected
    def collection
      @users ||= end_of_association_chain.order(:name)
    end
end

