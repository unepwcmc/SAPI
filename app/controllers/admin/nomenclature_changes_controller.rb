class Admin::NomenclatureChangesController < Admin::StandardAuthorizationController
  before_filter :redirect_in_production
  def index
    @nomenclature_changes = NomenclatureChange.includes([:event, :creator]).
      order('created_at DESC')
  end

  def show
    @nc = NomenclatureChange.find(params[:id])
  end

  def destroy
    @nomenclature_change = NomenclatureChange.find(params[:id])
    @nomenclature_change.destroy
    redirect_to admin_nomenclature_changes_path
  end

  protected

  def collection
    @collection ||= NomenclatureChange.includes([:event, :creator]).
      order('created_at DESC').page(params[:page]).per(10)
  end

end
