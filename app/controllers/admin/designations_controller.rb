class Admin::DesignationsController < Admin::SimpleCrudController
  respond_to :json, :only => [:index, :update]

  def index
    load_associations
    index! do |format|
      format.json {
        render :json => end_of_association_chain.order(:name).
          select([:id, :name]).map{ |d| {:value => d.id, :text => d.name} }
      }
    end
  end

  protected
    def collection
      @designations ||= end_of_association_chain.order(:name).page(params[:page])
    end

    def load_associations
      @taxonomies = Taxonomy.order(:name)
    end

end

