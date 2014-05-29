class Admin::NomenclatureChangesController < Admin::AdminController
  def index
    @nomenclature_changes = NomenclatureChange.order('created_at DESC')
  end

  def destroy
    @nomenclature_change = NomenclatureChange.find(params[:id])
    @nomenclature_change.destroy
    redirect_to admin_nomenclature_changes_path
  end

end
