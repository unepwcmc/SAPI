class Admin::DesignationsController < Admin::AdminController
  inherit_resources

  protected
    def collection
      @designations ||= end_of_association_chain.order(:name)
    end
end

