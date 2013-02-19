class Admin::ReferencesController < Admin::SimpleCrudController
  respond_to :json, :only => [:index, :update]

  def index
    index! do |format|
      format.json {
        render :json => end_of_association_chain.order(:title).
          select([:id, :title]).map{ |d| {:value => d.id, :text => d.title} }
      }
    end
  end

  protected
    def collection
      @references ||= end_of_association_chain.order(:title).page(params[:page])
    end
end

