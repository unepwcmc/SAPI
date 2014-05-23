class Admin::NomenclatureChangesController < Admin::AdminController
  def index
    @nomenclature_changes = NomenclatureChange.order('created_at DESC')
  end
end
