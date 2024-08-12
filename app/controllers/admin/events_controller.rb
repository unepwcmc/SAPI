class Admin::EventsController < Admin::StandardAuthorizationController
  respond_to :js, except: [:index, :destroy]
  respond_to :json, only: [:update, :show]

  def index
    load_associations
    index! do |format|
      format.json {
        render json: end_of_association_chain.order(:effective_at, :name).
          select([:id, :name]).map { |d| { value: d.id, text: d.name } }.to_json
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

  def show
    show! do |format|
      format.json { render json: resource, serializer: Admin::EventSerializer }
    end
  end

  protected

  def collection
    @events ||= end_of_association_chain.order(:designation_id, :name).
      includes(:designation).
      where(type: 'Event').page(params[:page]).
      search(params[:query])
  end

  def load_associations
    @designations = Designation.order(:name)
  end

  private

  def event_params
    params.require(:event).permit(
      # attributes were in model `attr_accessible`.
      :name, :designation_id, :description, :extended_description,
      :url, :private_url, :multilingual_url, :published_at, :effective_at, :is_current, :end_date,
      :created_by_id, :updated_by_id
    )
  end
end
