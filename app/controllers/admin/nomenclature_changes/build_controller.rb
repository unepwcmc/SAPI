class Admin::NomenclatureChanges::BuildController < Admin::AdminController
  include Wicked::Wizard

  before_filter :set_nomenclature_change, :only => [:show, :update, :destroy]

  def create
    @nomenclature_change = NomenclatureChange.create
    redirect_to wizard_path(steps.first, :nomenclature_change_id => @nomenclature_change.id)
  end

  def finish_wizard_path
    admin_nomenclature_changes_path
  end

  private

  def set_nomenclature_change
    @nomenclature_change = NomenclatureChange.find(params[:nomenclature_change_id])
  end

  def set_events
    @events = CitesCop.order('effective_at DESC')
  end

end