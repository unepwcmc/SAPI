class Admin::DesignationsController < Admin::SimpleCrudController

  protected
    def collection
      @designations ||= end_of_association_chain.order(:name).page(params[:page])
    end
end

