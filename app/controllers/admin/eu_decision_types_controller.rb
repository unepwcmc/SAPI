class Admin::EuDecisionTypesController < Admin::StandardAuthorizationController

  def index
    index! do |format|
      format.json {
        render :json => EuDecisionType.dict.sort.to_json
      }
    end
  end

  protected

  def collection
    @eu_decision_types ||= end_of_association_chain.page(params[:page]).
      order('UPPER(name) ASC')
  end
end
