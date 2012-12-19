class Admin::RanksController < Admin::SimpleCrudController
  inherit_resources

  def create
    @ranks = Rank.all
    super
  end

  protected

  def collection
    @ranks ||= end_of_association_chain.page(params[:page])
  end
end
