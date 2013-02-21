class Admin::EventsController < Admin::SimpleCrudController
  respond_to :json, :only => [:index, :update]

  def create
    @designations = Designation.order(:name)
    super
  end

  def index
    @designations = Designation.order(:name)
    index! do |format|
      format.json {
        render :json => end_of_association_chain.order(:name).
          select([:id, :name]).map{ |d| {:value => d.id, :text => d.name} }
      }
    end
  end

  protected
    def collection
      @events ||= end_of_association_chain.order(:designation_id, :name).page(params[:page])
    end
end

