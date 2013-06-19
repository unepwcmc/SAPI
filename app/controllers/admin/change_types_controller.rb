class Admin::ChangeTypesController < Admin::SimpleCrudController
  inherit_resources

  protected
    def collection
      @change_types ||= end_of_association_chain.includes(:designation).
        order('designation_id, name').
        page(params[:page])
    end

    def load_associations
      @designations = Designation.order(:name)
    end

end
