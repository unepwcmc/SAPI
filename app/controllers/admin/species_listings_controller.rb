class Admin::SpeciesListingsController < Admin::AdminController
  inherit_resources

  protected
    def collection
      @species_listings ||= end_of_association_chain.order('designation_id, name')
    end
end

