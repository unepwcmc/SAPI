class Admin::RanksController < Admin::SimpleCrudController
  inherit_resources

  def create
    super
    @ranks = Rank.all
  end

  protected

  def collection
    @ranks ||= end_of_association_chain.page(params[:page])
  end
end
