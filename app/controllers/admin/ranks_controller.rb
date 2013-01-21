class Admin::RanksController < Admin::SimpleCrudController

  protected

  def collection
    @ranks ||= end_of_association_chain.order(:taxonomic_position).page(params[:page])
  end
end
