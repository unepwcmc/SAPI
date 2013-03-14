class Admin::SpeciesListingsController < Admin::SimpleCrudController

  protected
    def collection
      @species_listings ||= end_of_association_chain.includes(:designation).
        order('designation_id, name').
        page(params[:page])
    end

    def load_associations
      @designations = Designation.order(:name)
    end

end
