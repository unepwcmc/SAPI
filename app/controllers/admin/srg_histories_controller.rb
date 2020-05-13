class Admin::SrgHistoriesController < Admin::StandardAuthorizationController

  def index
    index! do |format|
      format.json {
        render :json => SrgHistory.all.to_json
      }
    end
  end

  def create
    create! do |failure|
      failure.js { render 'new' }
    end
  end

  protected

  def collection
    @srg_histories ||= end_of_association_chain.page(params[:page]).
      order('UPPER(name) ASC')
  end
end
