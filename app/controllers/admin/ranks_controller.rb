class Admin::RanksController < Admin::StandardAuthorizationController
  protected

  def collection
    @ranks ||= end_of_association_chain.order(:taxonomic_position).page(params[:page])
  end

  private

  def rank_params
    params.require(:rank).permit(
      # attributes were in model `attr_accessible`.
      :name, :display_name_en, :display_name_es, :display_name_fr, :taxonomic_position, :fixed_order
    )
  end
end
