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
      order(Arel.sql('UPPER(name) ASC'))
  end

  private

  def eu_decision_type_params
    params.require(:eu_decision_type).permit(
      # attributes were in model `attr_accessible`.
      :name, :tooltip, :decision_type
    )
  end
end
