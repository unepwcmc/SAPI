class Admin::EuDecisionTypesController < Admin::SimpleCrudController

  def create
    create! do |failure|
      failure.js { render 'new' }
    end
  end
  protected

  def collection
    @eu_decision_types ||= end_of_association_chain.page(params[:page]).
      order('UPPER(name) ASC')
  end
end
