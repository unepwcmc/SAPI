class Admin::DesignationsController < Admin::SimpleCrudController
  respond_to :json, :only => [:index, :update]

  def index
    @taxonomies = Taxonomy.order(:name)
    index! do |format|
      format.json {
        render :json => end_of_association_chain.order(:name).
          select([:id, :name]).map{ |d| {:value => d.id, :text => d.name} }
      }
    end
  end

  def create
    @taxonomies = Taxonomy.order(:name)
    super
  end

  protected
    def collection
      @designations ||= end_of_association_chain.order(:name).page(params[:page])
    end
end

