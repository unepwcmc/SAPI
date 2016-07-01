class Admin::InstrumentsController < Admin::StandardAuthorizationController
  respond_to :json, :only => [:index, :update]

  def index
    load_associations
    index! do |format|
      format.json {
        render :text => end_of_association_chain.order(:name).
          select([:id, :name]).map { |d| { :value => d.id, :text => d.name } }.to_json
      }
    end
  end

  protected

  def collection
    @instruments ||= end_of_association_chain.order(:name).
      page(params[:page]).
      search(params[:query])
  end

  def load_associations
    @designations = Designation.order(:name)
  end
end
