class Admin::LanguagesController < Admin::StandardAuthorizationController
protected

  def collection
    @languages ||= end_of_association_chain.order(:iso_code3).
      page(params[:page]).
      search(params[:query])
  end

private

  def language_params
    params.require(:language).permit(
      # attributes were in model `attr_accessible`.
      :iso_code1, :iso_code3, :name_en, :name_fr, :name_es
    )
  end
end
