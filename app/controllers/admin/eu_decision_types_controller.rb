class Admin::EuDecisionTypesController < Admin::StandardAuthorizationController
  def index
    index! do |format|
      format.json do
        render json: EuDecisionType.dict.sort.to_json
      end
    end
  end

protected

  def collection
    @eu_decision_types ||= end_of_association_chain.order(
      Arel.sql('UPPER(name) ASC')
    ).page(
      params[:page]
    ).search(
      params[:query]
    )
  end

private

  def eu_decision_type_params
    params.expect(
      eu_decision_type: [
        :name, :tooltip, :decision_type
      ]
    )
  end
end
