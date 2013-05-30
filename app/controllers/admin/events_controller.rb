class Admin::EventsController < Admin::SimpleCrudController
  respond_to :js, :except => [:index, :destroy]
  respond_to :json, :only => [:update]

  def index
    load_associations
    index! do |format|
      format.json {
        render :json => end_of_association_chain.order(:effective_at, :name).
          select([:id, :name]).map{ |d| {:value => d.id, :text => d.name} }
      }
    end
  end

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
        where("type NOT IN ('EuRegulation', 'CitesCop', 'CitesSuspensionNotification')").page(params[:page])
    end

    def load_associations
      @designations = Designation.order(:name)
    end

end
