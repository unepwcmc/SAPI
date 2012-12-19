class Admin::DesignationsController < Admin::SimpleCrudController
  inherit_resources

  protected
    def collection
      @designations ||= end_of_association_chain.order(:name).page(params[:page])
    end
end

