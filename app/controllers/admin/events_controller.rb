class Admin::EventsController < Admin::SimpleCrudController
  respond_to :js, :except => [:index, :destroy]
  respond_to :json, :only => [:update]

  def new
    new! do
      load_associations
    end
  end

  def edit
    edit! do |format|
      load_associations
      format.js { render 'new' }
    end
  end

  protected
    def collection
      @events ||= end_of_association_chain.order(:designation_id, :name).
        where("type != 'EuRegulation'").page(params[:page])
    end

    def load_associations
      @designations = Designation.order(:name)
    end

end
