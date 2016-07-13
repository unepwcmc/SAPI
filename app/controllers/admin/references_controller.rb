class Admin::ReferencesController < Admin::StandardAuthorizationController
  respond_to :json, :only => [:index, :update]

  def index
    index! do |format|
      format.json {
        render :text => end_of_association_chain.order(:citation).
          select([:id, :citation]).map { |d| { :value => d.id, :text => d.citation } }.to_json
      }
    end
  end

  def autocomplete
    @references = Reference.search(params[:query]).
      order(:citation)
    @references.map! do |r|
      {
        :id => r.id,
        :value => r.citation
      }
    end

    render :json => @references.to_json
  end

  protected

  def collection
    @references ||= end_of_association_chain.order(:citation).
      page(params[:page]).
      search(params[:query])
  end
end
