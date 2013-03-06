class Admin::SpeciesListingsController < Admin::SimpleCrudController

  def index
    @designations = Designation.order(:name)
    index!
  end

  def create
    @designations = Designation.order(:name)
    super
  end

  protected
    def collection
      @species_listings ||= end_of_association_chain.includes(:designation).
        order('designation_id, species_listings.name').
        page(params[:page]).
        search(params[:query])
    end
end

